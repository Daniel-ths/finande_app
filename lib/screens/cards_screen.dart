import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/credit_card.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: provider.cards.isEmpty
          ? Center(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_outlined, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum cartão cadastrado',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                ],
              ).animate().fadeIn(duration: 250.ms),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: provider.cards.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.cards.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () => _showAddCardDialog(context, provider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Novo cartão',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (50 * index).ms, duration: 250.ms),
                  );
                }

                final card = provider.cards[index];
                final percentUsed = card.limit > 0 ? (card.used / card.limit) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.credit_card, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              card.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CardInfo(label: 'Limite', value: currency.format(card.limit)),
                          _CardInfo(label: 'Usado', value: currency.format(card.used), color: AppColors.danger),
                          _CardInfo(label: 'Disponível', value: currency.format(card.available), color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentUsed.clamp(0.0, 1.0),
                          backgroundColor: AppColors.border,
                          color: percentUsed > 0.8 ? AppColors.danger : AppColors.primary,
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Fecha dia ${card.closingDay}  •  Vence dia ${card.dueDay}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: (70 * index).ms, duration: 450.ms)
                    .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
              },
            ),
    );
  }

  void _showAddCardDialog(BuildContext context, FinanceProvider provider) {
    final nameController = TextEditingController();
    final limitController = TextEditingController();
    final closingController = TextEditingController(text: '5');
    final dueController = TextEditingController(text: '12');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Novo Cartão', style: TextStyle(color: AppColors.text)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(labelText: 'Nome do cartão'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(labelText: 'Limite', prefixText: 'R\$ '),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: closingController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(labelText: 'Fecha dia'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: dueController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(labelText: 'Vence dia'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final limit = double.tryParse(limitController.text.replaceAll(',', '.'));
              final closing = int.tryParse(closingController.text);
              final due = int.tryParse(dueController.text);

              if (name.isEmpty || limit == null || closing == null || due == null) return;

              provider.addCreditCard(CreditCard(
                name: name,
                limit: limit,
                closingDay: closing,
                dueDay: due,
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

class _CardInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _CardInfo({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}
