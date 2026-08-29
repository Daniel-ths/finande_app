import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/money_item.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class MoneyItemsScreen extends StatelessWidget {
  final MoneyItemType type;
  final String title;
  final String emptyText;
  final IconData icon;

  const MoneyItemsScreen({
    super.key,
    required this.type,
    required this.title,
    required this.emptyText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final items = provider.itemsOf(type);
    final pending = items.where((e) => !e.isPaidOrReceived).toList();
    final totalPending = pending.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, provider),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(emptyText, style: const TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showAddDialog(context, provider),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (totalPending > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: type == MoneyItemType.loanToReceive
                              ? AppColors.primary
                              : AppColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            type == MoneyItemType.loanToReceive
                                ? 'A receber'
                                : 'Pendente',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                        Text(
                          currency.format(totalPending),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: type == MoneyItemType.loanToReceive
                                ? AppColors.primary
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ...items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => provider.toggleMoneyItem(item.id),
                          child: Icon(
                            item.isPaidOrReceived
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: item.isPaidOrReceived
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                  decoration: item.isPaidOrReceived
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              if (item.notes != null && item.notes!.isNotEmpty)
                                Text(
                                  item.notes!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          currency.format(item.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: type == MoneyItemType.loanToReceive
                                ? AppColors.primary
                                : AppColors.text,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
                          onPressed: () => provider.deleteMoneyItem(item.id),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  void _showAddDialog(BuildContext context, FinanceProvider provider) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(labelText: 'Obs (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
              if (name.isEmpty || amount == null || amount <= 0) return;

              provider.addMoneyItem(MoneyItem(
                type: type,
                name: name,
                amount: amount,
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
