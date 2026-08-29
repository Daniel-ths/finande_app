import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/account.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: provider.accounts.isEmpty
          ? Center(
              child: const Text(
                'Nenhuma conta cadastrada',
                style: TextStyle(color: AppColors.textMuted),
              ).animate().fadeIn(),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: provider.accounts.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.accounts.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () => _showAddAccountDialog(context, provider),
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
                              'Nova conta',
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
                        .fadeIn(delay: (50 * index).ms, duration: 400.ms),
                  );
                }

                final account = provider.accounts[index];
                final color = Color(int.parse(account.color.replaceFirst('#', '0xFF')));

                return GestureDetector(
                  onTap: () => _showEditBalanceDialog(context, provider, account),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.account_balance_wallet, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _accountTypeLabel(account.type),
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currency.format(account.balance),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: account.balance >= 0 ? AppColors.primary : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (60 * index).ms, duration: 400.ms)
                    .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
              },
            ),
    );
  }

  String _accountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'Conta Corrente';
      case AccountType.digital:
        return 'Conta Digital';
      case AccountType.savings:
        return 'Poupança';
      case AccountType.cash:
        return 'Dinheiro';
      case AccountType.digitalWallet:
        return 'Carteira Digital';
    }
  }

  void _showAddAccountDialog(BuildContext context, FinanceProvider provider) {
    final nameController = TextEditingController();
    AccountType selectedType = AccountType.digital;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Nova Conta', style: TextStyle(color: AppColors.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(labelText: 'Nome da conta'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                initialValue: selectedType,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(labelText: 'Tipo'),
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
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                provider.addAccount(Account(
                  name: nameController.text.trim(),
                  type: selectedType,
                ));
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
    final controller = TextEditingController(
      text: account.balance.toStringAsFixed(2).replaceAll('.', ','),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Saldo - ${account.name}', style: const TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(
            labelText: 'Novo saldo',
            prefixText: 'R\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.replaceAll(',', '.'));
              if (value != null) {
                provider.updateAccountBalance(account.id, value);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }
}
