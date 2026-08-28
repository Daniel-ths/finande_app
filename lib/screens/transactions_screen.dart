import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final sorted = List<Transaction>.from(provider.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              );
            },
          ),
        ],
      ),
      body: sorted.isEmpty
          ? const Center(
              child: Text(
                'Nenhum lançamento ainda.\nToque no + para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final t = sorted[index];
                final category = provider.categories.where((c) => c.id == t.categoryId).firstOrNull;
                final isIncome = t.type == TransactionType.income;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                      child: Text(category?.icon ?? '📦', style: const TextStyle(fontSize: 18)),
                    ),
                    title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('${category?.name ?? 'Sem categoria'} • ${DateFormat('dd/MM/yyyy').format(t.date)}'),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}${currency.format(t.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Excluir lançamento?'),
                          content: Text('Deseja excluir "${t.description}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                            FilledButton(
                              onPressed: () {
                                provider.deleteTransaction(t.id);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
