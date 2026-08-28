import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/credit_card.dart';
import '../providers/finance_provider.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCardDialog(context, provider),
          ),
        ],
      ),
      body: provider.cards.isEmpty
          ? const Center(
              child: Text(
                'Nenhum cartão cadastrado.\nToque no + para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.cards.length,
              itemBuilder: (context, index) {
                final card = provider.cards[index];
                final color = Color(int.parse(card.color.replaceFirst('#', '0xFF')));
                final percentUsed = card.limit > 0 ? (card.used / card.limit) : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: color.withOpacity(0.2),
                              child: Icon(Icons.credit_card, color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(card.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _InfoItem(label: 'Limite', value: currency.format(card.limit)),
                            _InfoItem(label: 'Utilizado', value: currency.format(card.used), valueColor: Colors.red),
                            _InfoItem(label: 'Disponível', value: currency.format(card.available), valueColor: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percentUsed.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          color: percentUsed > 0.8 ? Colors.red : color,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fechamento: dia ${card.closingDay}  •  Vencimento: dia ${card.dueDay}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
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
        title: const Text('Novo Cartão'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do cartão', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Limite', prefixText: 'R\$ ', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: closingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Dia fechamento', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: dueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Dia vencimento', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
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

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
