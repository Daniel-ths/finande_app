import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
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
  const _HomeTab({super.key});

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
          style: TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w500),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),

        const SizedBox(height: 4),

        Text(
          currency.format(provider.realAvailableBalance),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -1.2,
          ),
        ).animate().fadeIn(delay: 80.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 4),

        Text(
          'Nas contas: ${currency.format(provider.totalBalance)}',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 20),

        // Pode gastar hoje
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Pode gastar hoje', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
              ),
              Text(
                currency.format(provider.dailyLimit),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 28),

        // Este mês
        const Text(
          'Este mês',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
        ).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _InfoCard(
                label: 'Receitas',
                value: currency.format(provider.monthlyIncome),
                color: AppColors.primary,
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.08, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                label: 'Despesas',
                value: currency.format(provider.monthlyExpenses),
                color: AppColors.danger,
              ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.08, end: 0),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Ações
        const Text(
          'Ações',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.add_circle_outline,
                label: 'Receita',
                onTap: () {
                  Navigator.of(context).push(
                    AppTransitions.slideFromBottom(const AddTransactionScreen()),
                  );
                },
              ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.92, 0.92)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.remove_circle_outline,
                label: 'Despesa',
                onTap: () {
                  Navigator.of(context).push(
                    AppTransitions.slideFromBottom(const AddTransactionScreen()),
                  );
                },
              ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.92, 0.92)),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.calendar_view_month_outlined,
                label: 'Parcelas',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InstallmentsScreen()),
                  );
                },
              ).animate().fadeIn(delay: 550.ms).scale(begin: const Offset(0.92, 0.92)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.flag_outlined,
                label: 'Metas',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  );
                },
              ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.92, 0.92)),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Botão de análise de recorrentes
        _ActionButton(
          icon: Icons.analytics_outlined,
          label: 'Gastos que se repetem',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecurringAnalysisScreen()),
            );
          },
        ).animate().fadeIn(delay: 650.ms).scale(begin: const Offset(0.92, 0.92)),

        const SizedBox(height: 28),

        // Próximos vencimentos
        if (provider.futureExpenses.where((e) => !e.isPaid).isNotEmpty) ...[
          const Text(
            'Próximos vencimentos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
          ).animate().fadeIn(delay: 700.ms),
          const SizedBox(height: 12),
          ...provider.futureExpenses.where((e) => !e.isPaid).take(4).toList().asMap().entries.map((entry) {
            final e = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.description, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                        Text(DateFormat('dd/MM').format(e.dueDate), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(
                    currency.format(e.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (750 + entry.key * 50).ms).slideY(begin: 0.1, end: 0);
          }),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoCard({required this.label, required this.value, required this.color});

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
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color ?? AppColors.text, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color ?? AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
