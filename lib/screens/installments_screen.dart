import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/installment_purchase.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class InstallmentsScreen extends StatelessWidget {
  const InstallmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final active = provider.installments.where((i) => !i.isCompleted).toList();
    final completed = provider.installments.where((i) => i.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Parcelas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, provider),
          ),
        ],
      ),
      body: provider.installments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_view_month_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('Nenhuma compra parcelada', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Ex: celular 12x, notebook, roupa...', style: TextStyle(color: AppColors.textMuted.withOpacity(0.7), fontSize: 13)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showAddDialog(context, provider),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova parcela'),
                  ),
                ],
              ).animate().fadeIn(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (provider.totalRemainingInstallments > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Ainda deve em parcelas', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
                        Text(
                          currency.format(provider.totalRemainingInstallments),
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger, fontSize: 15),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                ...active.asMap().entries.map((e) {
                  return _InstallmentCard(item: e.value, currency: currency)
                      .animate()
                      .fadeIn(delay: (50 * e.key).ms)
                      .slideY(begin: 0.1, end: 0);
                }),

                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Concluídas', style: TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...completed.map((item) => _InstallmentCard(item: item, currency: currency, dimmed: true)),
                ],
              ],
            ),
    );
  }

  void _showAddDialog(BuildContext context, FinanceProvider provider) {
    final descController = TextEditingController();
    final totalController = TextEditingController();
    final installmentsController = TextEditingController(text: '12');
    DateTime startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final total = double.tryParse(totalController.text.replaceAll(',', '.')) ?? 0;
          final qty = int.tryParse(installmentsController.text) ?? 1;
          final parcelValue = qty > 0 ? total / qty : 0.0;

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Nova compra parcelada', style: TextStyle(color: AppColors.text)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(labelText: 'O que foi comprado'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(labelText: 'Valor total', prefixText: 'R\$ '),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: installmentsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(labelText: 'Quantidade de parcelas'),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (parcelValue > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${qty}x de ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(parcelValue)}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Data da 1ª parcela', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate), style: const TextStyle(color: AppColors.text)),
                    trailing: const Icon(Icons.calendar_today, size: 18, color: AppColors.textMuted),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) setState(() => startDate = date);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
              FilledButton(
                onPressed: () {
                  final desc = descController.text.trim();
                  final totalVal = double.tryParse(totalController.text.replaceAll(',', '.'));
                  final qtyVal = int.tryParse(installmentsController.text);
                  if (desc.isEmpty || totalVal == null || qtyVal == null || qtyVal < 1) return;

                  provider.addInstallment(InstallmentPurchase(
                    description: desc,
                    totalAmount: totalVal,
                    totalInstallments: qtyVal,
                    installmentValue: totalVal / qtyVal,
                    startDate: startDate,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InstallmentCard extends StatelessWidget {
  final InstallmentPurchase item;
  final NumberFormat currency;
  final bool dimmed;

  const _InstallmentCard({required this.item, required this.currency, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FinanceProvider>();

    return Opacity(
      opacity: dimmed ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                ),
                Text(
                  '${item.paidInstallments}/${item.totalInstallments}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${currency.format(item.installmentValue)} • Total ${currency.format(item.totalAmount)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress,
                backgroundColor: AppColors.border,
                color: item.isCompleted ? AppColors.primary : AppColors.primary,
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 8),
            if (!item.isCompleted) ...[
              Text(
                'Faltam ${item.remainingInstallments}x = ${currency.format(item.remainingAmount)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              if (item.nextDueDate != null)
                Text(
                  'Próxima: ${DateFormat('dd/MM').format(item.nextDueDate!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => provider.payInstallment(item.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Marcar parcela como paga'),
                ),
              ),
            ] else
              const Text('Quitado ✓', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
