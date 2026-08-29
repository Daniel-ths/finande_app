import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';

class MonthlySheetScreen extends StatefulWidget {
  const MonthlySheetScreen({super.key});

  @override
  State<MonthlySheetScreen> createState() => _MonthlySheetScreenState();
}

class _MonthlySheetScreenState extends State<MonthlySheetScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final incomes = provider.transactions.where((t) =>
        t.type == TransactionType.income &&
        t.date.month == _selectedMonth.month &&
        t.date.year == _selectedMonth.year);

    final expenses = provider.transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.month == _selectedMonth.month &&
        t.date.year == _selectedMonth.year);

    final totalIncome = incomes.fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    final Map<String, double> byCategory = {};
    for (final e in expenses) {
      final cat = provider.categories.where((c) => c.id == e.categoryId).firstOrNull;
      final name = cat?.name ?? 'Outros';
      byCategory[name] = (byCategory[name] ?? 0) + e.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Planilha Mensal')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy', 'pt_BR').format(_selectedMonth).toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _SummaryBox(label: 'Receitas', value: currency.format(totalIncome), color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _SummaryBox(label: 'Despesas', value: currency.format(totalExpense), color: Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _SummaryBox(label: 'Saldo', value: currency.format(balance), color: balance >= 0 ? Colors.blue : Colors.orange)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: byCategory.isEmpty
                ? const Center(child: Text('Nenhum lançamento neste mês'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Despesas por categoria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ...byCategory.entries.map((entry) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(entry.key),
                            trailing: Text(
                              currency.format(entry.value),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
