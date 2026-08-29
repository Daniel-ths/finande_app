import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class RecurringAnalysisScreen extends StatelessWidget {
  const RecurringAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final insights = provider.recurringInsights;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Gastos recorrentes')),
      body: insights == null || insights.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('Ainda sem padrão detectado', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(
                    'Lance mais despesas com o mesmo nome\npara o app identificar recorrência',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ).animate().fadeIn(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                  child: const Text(
                    'O app detecta gastos que se repetem e mostra frequência e média.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 16),
                ...insights.asMap().entries.map((entry) {
                  final insight = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                insight.description,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                insight.frequency,
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _MiniStat(label: 'Vezes', value: '${insight.count}x'),
                            _MiniStat(label: 'Média', value: currency.format(insight.averageAmount)),
                            _MiniStat(label: 'Total', value: currency.format(insight.totalSpent)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Última: ${DateFormat('dd/MM/yyyy').format(insight.lastDate)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (50 * entry.key).ms)
                      .slideY(begin: 0.1, end: 0);
                }),
              ],
            ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
        ],
      ),
    );
  }
}
