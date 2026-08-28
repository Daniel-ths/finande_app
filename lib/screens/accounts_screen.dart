import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../providers/finance_provider.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(context, provider),
          ),
        ],
      ),
      body: provider.accounts.isEmpty
          ? const Center(child: Text('Nenhuma conta cadastrada'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.accounts.length,
              itemBuilder: (context, index) {
                final account = provider.accounts[index];
                final color = Color(int.parse(account.color.replaceFirst('#', '0xFF')));

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(Icons.account_balance_wallet, color: color),
                    ),
                    title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_accountTypeLabel(account.type)),
                    trailing: Text(
                      currency.format(account.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: account.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    onTap: () => _showEditBalanceDialog(context, provider, account),
                  ),
                );
              },
            ),
    );
  }

  String _accountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.checking: return 'Conta Corrente';
      case AccountType.digital: return 'Conta Digital';
      case AccountType.savings: return 'Poupança';
      case AccountType.cash: return 'Dinheiro';
      case AccountType.digitalWallet: return 'Carteira Digital';
    }
  }

  void _showAddAccountDialog(BuildContext context, FinanceProvider provider) {
    final nameController = TextEditingController();
    AccountType selectedType = AccountType.digital;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome da conta', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                items: AccountType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(_accountTypeLabel(type)));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedType = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                provider.addAccount(Account(name: nameController.text.trim(), type: selectedType));
                Navigator.pop(ctx);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBalanceDialog(BuildContext context, FinanceProvider provider, Account account) {
    final controller = TextEditingController(text: account.balance.toStringAsFixed(2).replaceAll('.', ','));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Saldo - ${account.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Novo saldo', prefixText: 'R\$ ', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.replaceAll(',', '.'));
              if (value != null) provider.updateAccountBalance(account.id, value);
              Navigator.pop(ctx);
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }
}
