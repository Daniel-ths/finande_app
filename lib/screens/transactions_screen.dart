import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final sorted = List<Transaction>.from(provider.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: sorted.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum lançamento ainda',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no + para adicionar',
                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.7), fontSize: 13),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final t = sorted[index];
                final category = provider.categories.where((c) => c.id == t.categoryId).firstOrNull;
                final isIncome = t.type == TransactionType.income;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isIncome ? AppColors.successSoft : AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            category?.icon ?? '📦',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${category?.name ?? 'Sem categoria'} • ${DateFormat('dd/MM').format(t.date)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'}${currency.format(t.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isIncome ? AppColors.primary : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: (50 * index).ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
              },
            ),
    );
  }
}
