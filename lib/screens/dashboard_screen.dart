import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/money_item.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_transitions.dart';
import 'add_transaction_screen.dart';
import 'transactions_screen.dart';
import 'accounts_screen.dart';
import 'cards_screen.dart';
import 'monthly_sheet_screen.dart';
import 'goals_screen.dart';
import 'installments_screen.dart';
import 'recurring_analysis_screen.dart';
import 'money_items_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    TransactionsScreen(),
    CardsScreen(),
    AccountsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'MeuLimite',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        AppTransitions.slideFromRight(const MonthlySheetScreen()),
                      );
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 22),
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        AppTransitions.slideFromBottom(const AddTransactionScreen()),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _pages[_currentIndex],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TabItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_filled,
                    label: 'Início',
                    selected: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _TabItem(
                    icon: Icons.list_alt_outlined,
                    activeIcon: Icons.list_alt,
                    label: 'Gastos',
                    selected: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _TabItem(
                    icon: Icons.credit_card_outlined,
                    activeIcon: Icons.credit_card,
                    label: 'Cartões',
                    selected: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _TabItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet,
                    label: 'Contas',
                    selected: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? activeIcon : icon,
            size: 24,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text(
          'Disponível agora',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currency.format(provider.realAvailableBalance),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Saldo em contas: ${currency.format(provider.totalBalance)}',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),

        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Pode gastar hoje',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                currency.format(provider.dailyLimit),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        const Text(
          'Este mês',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _SimpleCard(
                label: 'Receitas',
                value: currency.format(provider.monthlyIncome),
                valueColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SimpleCard(
                label: 'Despesas',
                value: currency.format(provider.monthlyExpenses),
                valueColor: AppColors.danger,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        const Text(
          'Ações rápidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            _QuickAction(
              icon: Icons.add,
              label: 'Receita',
              onTap: () {
                Navigator.of(context).push(
                  AppTransitions.slideFromBottom(const AddTransactionScreen()),
                );
              },
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.remove,
              label: 'Despesa',
              onTap: () {
                Navigator.of(context).push(
                  AppTransitions.slideFromBottom(const AddTransactionScreen()),
                );
              },
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.calendar_view_month,
              label: 'Parcelas',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InstallmentsScreen()),
                );
              },
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.flag_outlined,
              label: 'Metas',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GoalsScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 32),

        const Text(
          'Organizar o mês',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 14),

        _MenuTile(
          icon: Icons.tv_outlined,
          title: 'Planos de streaming',
          subtitle: provider.totalStreaming > 0
              ? currency.format(provider.totalStreaming)
              : 'Netflix, Spotify...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MoneyItemsScreen(
                  type: MoneyItemType.streaming,
                  title: 'Planos de streaming',
                  emptyText: 'Nenhum streaming cadastrado',
                  icon: Icons.tv_outlined,
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.home_outlined,
          title: 'Gastos fixos',
          subtitle: provider.totalFixedExpenses > 0
              ? currency.format(provider.totalFixedExpenses)
              : 'Aluguel, internet...',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MoneyItemsScreen(
                  type: MoneyItemType.fixedExpense,
                  title: 'Gastos fixos',
                  emptyText: 'Nenhum gasto fixo',
                  icon: Icons.home_outlined,
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.flash_on_outlined,
          title: 'Gastos extras',
          subtitle: provider.totalExtraExpenses > 0
              ? currency.format(provider.totalExtraExpenses)
              : 'Imprevistos do mês',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MoneyItemsScreen(
                  type: MoneyItemType.extraExpense,
                  title: 'Gastos extras',
                  emptyText: 'Nenhum gasto extra',
                  icon: Icons.flash_on_outlined,
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.handshake_outlined,
          title: 'Empréstimos a receber',
          subtitle: provider.totalLoansToReceive > 0
              ? currency.format(provider.totalLoansToReceive)
              : 'Quem te deve',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MoneyItemsScreen(
                  type: MoneyItemType.loanToReceive,
                  title: 'Empréstimos a receber',
                  emptyText: 'Ninguém te deve nada',
                  icon: Icons.handshake_outlined,
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.shopping_bag_outlined,
          title: 'Comprar no mês',
          subtitle: provider.totalMonthlyNeeds > 0
              ? currency.format(provider.totalMonthlyNeeds)
              : 'Lista de necessidades',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MoneyItemsScreen(
                  type: MoneyItemType.monthlyNeed,
                  title: 'Necessidades do mês',
                  emptyText: 'Lista vazia',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.analytics_outlined,
          title: 'Gastos que se repetem',
          subtitle: 'Análise automática',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecurringAnalysisScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _SimpleCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SimpleCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.text, size: 22),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.text, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
