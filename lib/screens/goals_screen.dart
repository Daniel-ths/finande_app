import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/goal.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context, provider),
          ),
        ],
      ),
      body: provider.goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text('Nenhuma meta ainda', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Crie uma meta e comece a juntar',
                    style: TextStyle(color: AppColors.textMuted.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showAddGoalDialog(context, provider),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova meta'),
                  ),
                ],
              ).animate().fadeIn(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (provider.totalReservedInGoals > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Reservado nas metas', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ),
                        Text(
                          currency.format(provider.totalReservedInGoals),
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ...provider.goals.asMap().entries.map((entry) {
                  return _GoalCard(goal: entry.value, currency: currency)
                      .animate()
                      .fadeIn(delay: (60 * entry.key).ms, duration: 400.ms)
                      .slideY(begin: 0.12, end: 0);
                }),
              ],
            ),
    );
  }

  void _showAddGoalDialog(BuildContext context, FinanceProvider provider) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? selectedDeadline;
    String selectedIcon = '🎯';
    final icons = ['🎯', '💻', '🏠', '🚗', '✈️', '📱', '🎓', '💰'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Nova meta', style: TextStyle(color: AppColors.text)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(labelText: 'Nome da meta'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(labelText: 'Valor objetivo', prefixText: 'R\$ '),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Prazo (opcional)', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  subtitle: Text(
                    selectedDeadline != null
                        ? DateFormat('dd/MM/yyyy').format(selectedDeadline!)
                        : 'Sem prazo definido',
                    style: const TextStyle(color: AppColors.text),
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20, color: AppColors.textMuted),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 90)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date != null) setState(() => selectedDeadline = date);
                  },
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Ícone', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: icons.map((icon) {
                    final selected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: selected ? Border.all(color: AppColors.primary, width: 1.5) : null,
                        ),
                        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
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
                final target = double.tryParse(targetController.text.replaceAll(',', '.'));
                if (name.isEmpty || target == null || target <= 0) return;

                provider.addGoal(Goal(
                  name: name,
                  targetAmount: target,
                  deadline: selectedDeadline,
                  icon: selectedIcon,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final NumberFormat currency;

  const _GoalCard({required this.goal, required this.currency});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FinanceProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(
                      '${currency.format(goal.currentAmount)} de ${currency.format(goal.targetAmount)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: goal.isCompleted ? AppColors.primary : AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          if (goal.isCompleted)
            const Text('Meta concluída!', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600))
          else ...[
            Text('Faltam ${currency.format(goal.remaining)}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            if (goal.deadline != null && goal.monthlyNeeded > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Guarde ${currency.format(goal.monthlyNeeded)}/mês para chegar no prazo',
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showAddMoneyDialog(context, provider, goal),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Adicionar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: goal.currentAmount > 0 ? () => _showRemoveMoneyDialog(context, provider, goal) : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Retirar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, FinanceProvider provider, Goal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Adicionar em ${goal.name}', style: const TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) provider.addToGoal(goal.id, amount);
              Navigator.pop(ctx);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMoneyDialog(BuildContext context, FinanceProvider provider, Goal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Retirar de ${goal.name}', style: const TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) provider.removeFromGoal(goal.id, amount);
              Navigator.pop(ctx);
            },
            child: const Text('Retirar'),
          ),
        ],
      ),
    );
  }
}
