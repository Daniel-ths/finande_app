import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/credit_card.dart';
import '../models/future_expense.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/installment_purchase.dart';
import '../models/money_item.dart';
import '../services/storage_service.dart';

class FinanceProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Account> accounts = [];
  List<Category> categories = [];
  List<CreditCard> cards = [];
  List<Transaction> transactions = [];
  List<FutureExpense> futureExpenses = [];
  List<Goal> goals = [];
  List<InstallmentPurchase> installments = [];
  List<MoneyItem> moneyItems = [];

  bool isLoading = true;

  double get totalBalance => accounts.fold(0.0, (sum, a) => sum + a.balance);

  double get totalFutureExpenses {
    final now = DateTime.now();
    return futureExpenses
        .where((e) => !e.isPaid && e.dueDate.isAfter(now.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalRemainingInstallments => installments
      .where((i) => !i.isCompleted)
      .fold(0.0, (sum, i) => sum + i.remainingAmount);

  double get currentMonthInstallments {
    final now = DateTime.now();
    return installments.where((i) {
      if (i.isCompleted) return false;
      final next = i.nextDueDate;
      if (next == null) return false;
      return next.month == now.month && next.year == now.year;
    }).fold(0.0, (sum, i) => sum + i.installmentValue);
  }

  double get totalReservedInGoals => goals
      .where((g) => !g.isCompleted)
      .fold(0.0, (sum, g) => sum + g.currentAmount);

  double get totalStreaming => moneyItems
      .where((e) => e.type == MoneyItemType.streaming && !e.isPaidOrReceived)
      .fold(0.0, (s, e) => s + e.amount);

  double get totalFixedExpenses => moneyItems
      .where((e) => e.type == MoneyItemType.fixedExpense && !e.isPaidOrReceived)
      .fold(0.0, (s, e) => s + e.amount);

  double get totalExtraExpenses => moneyItems
      .where((e) => e.type == MoneyItemType.extraExpense && !e.isPaidOrReceived)
      .fold(0.0, (s, e) => s + e.amount);

  double get totalLoansToReceive => moneyItems
      .where((e) => e.type == MoneyItemType.loanToReceive && !e.isPaidOrReceived)
      .fold(0.0, (s, e) => s + e.amount);

  double get totalMonthlyNeeds => moneyItems
      .where((e) => e.type == MoneyItemType.monthlyNeed && !e.isPaidOrReceived)
      .fold(0.0, (s, e) => s + e.amount);

  double get realAvailableBalance =>
      totalBalance -
      totalFutureExpenses -
      currentMonthInstallments -
      totalReservedInGoals -
      totalStreaming -
      totalFixedExpenses -
      totalExtraExpenses -
      totalMonthlyNeeds +
      totalLoansToReceive;

  double get monthlyIncome {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpenses {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get dailyLimit {
    final remainingDays =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day -
            DateTime.now().day +
            1;
    if (remainingDays <= 0 || realAvailableBalance <= 0) return 0;
    return realAvailableBalance / remainingDays;
  }

  List<RecurringInsight> get recurringInsights {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return <RecurringInsight>[];

    final Map<String, List<Transaction>> groups = {};
    for (final t in expenses) {
      final key = t.description.trim().toLowerCase();
      groups.putIfAbsent(key, () => []).add(t);
    }

    final insights = <RecurringInsight>[];
    for (final entry in groups.entries) {
      final list = entry.value;
      if (list.length < 2) continue;
      list.sort((a, b) => a.date.compareTo(b.date));
      final avgAmount = list.fold(0.0, (s, t) => s + t.amount) / list.length;
      double totalGap = 0;
      for (var i = 1; i < list.length; i++) {
        totalGap += list[i].date.difference(list[i - 1].date).inDays;
      }
      final avgGap = list.length > 1 ? totalGap / (list.length - 1) : 0.0;

      String frequency;
      if (avgGap <= 10) {
        frequency = 'Semanal';
      } else if (avgGap <= 20) {
        frequency = 'Quinzenal';
      } else if (avgGap <= 40) {
        frequency = 'Mensal';
      } else if (avgGap <= 100) {
        frequency = 'Trimestral';
      } else {
        frequency = 'Esporádico';
      }

      insights.add(RecurringInsight(
        description: list.first.description,
        count: list.length,
        averageAmount: avgAmount,
        frequency: frequency,
        lastDate: list.last.date,
        totalSpent: list.fold(0.0, (s, t) => s + t.amount),
      ));
    }
    insights.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    return insights;
  }

  List<MoneyItem> itemsOf(MoneyItemType type) =>
      moneyItems.where((e) => e.type == type).toList();

  Future<void> loadData() async {
    accounts = await _storage.loadAccounts();
    categories = await _storage.loadCategories();
    cards = await _storage.loadCards();
    transactions = await _storage.loadTransactions();
    futureExpenses = await _storage.loadFutureExpenses();
    goals = await _storage.loadGoals();
    installments = await _storage.loadInstallments();
    moneyItems = await _storage.loadMoneyItems();

    if (categories.isEmpty) _createDefaultCategories();
    if (accounts.isEmpty) _createDefaultAccounts();

    isLoading = false;
    notifyListeners();
  }

  void _createDefaultCategories() {
    categories = [
      Category(name: 'Casa', icon: '🏠', color: '#795548', isDefault: true),
      Category(name: 'Alimentação', icon: '🍔', color: '#FF5722', isDefault: true),
      Category(name: 'Transporte', icon: '🚗', color: '#2196F3', isDefault: true),
      Category(name: 'Lazer', icon: '🎮', color: '#9C27B0', isDefault: true),
      Category(name: 'Tecnologia', icon: '💻', color: '#607D8B', isDefault: true),
      Category(name: 'Salário', icon: '💰', color: '#4CAF50', isDefault: true),
      Category(name: 'Freelance', icon: '💻', color: '#8BC34A', isDefault: true),
      Category(name: 'Outros', icon: '📦', color: '#9E9E9E', isDefault: true),
    ];
    _storage.saveCategories(categories);
  }

  void _createDefaultAccounts() {
    accounts = [
      Account(name: 'Nubank', type: AccountType.digital, balance: 0, color: '#820AD1'),
      Account(name: 'Banco do Brasil', type: AccountType.checking, balance: 0, color: '#FFCC00'),
      Account(name: 'Dinheiro', type: AccountType.cash, balance: 0, color: '#4CAF50'),
    ];
    _storage.saveAccounts(accounts);
  }

  Future<void> addTransaction(Transaction transaction) async {
    transactions.add(transaction);
    final accountIndex = accounts.indexWhere((a) => a.id == transaction.accountId);
    if (accountIndex != -1) {
      if (transaction.type == TransactionType.income) {
        accounts[accountIndex].balance += transaction.amount;
      } else {
        accounts[accountIndex].balance -= transaction.amount;
      }
      await _storage.saveAccounts(accounts);
    }
    await _storage.saveTransactions(transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final transaction = transactions.firstWhere((t) => t.id == id);
    final accountIndex = accounts.indexWhere((a) => a.id == transaction.accountId);
    if (accountIndex != -1) {
      if (transaction.type == TransactionType.income) {
        accounts[accountIndex].balance -= transaction.amount;
      } else {
        accounts[accountIndex].balance += transaction.amount;
      }
      await _storage.saveAccounts(accounts);
    }
    transactions.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(transactions);
    notifyListeners();
  }

  Future<void> addFutureExpense(FutureExpense expense) async {
    futureExpenses.add(expense);
    await _storage.saveFutureExpenses(futureExpenses);
    notifyListeners();
  }

  Future<void> markFutureExpenseAsPaid(String id) async {
    final index = futureExpenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final old = futureExpenses[index];
      futureExpenses[index] = FutureExpense(
        id: old.id,
        description: old.description,
        amount: old.amount,
        dueDate: old.dueDate,
        categoryId: old.categoryId,
        accountId: old.accountId,
        isPaid: true,
      );
      await _storage.saveFutureExpenses(futureExpenses);
      notifyListeners();
    }
  }

  Future<void> addCreditCard(CreditCard card) async {
    cards.add(card);
    await _storage.saveCards(cards);
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    accounts.add(account);
    await _storage.saveAccounts(accounts);
    notifyListeners();
  }

  Future<void> updateAccountBalance(String id, double newBalance) async {
    final index = accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      accounts[index].balance = newBalance;
      await _storage.saveAccounts(accounts);
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    goals.add(goal);
    await _storage.saveGoals(goals);
    notifyListeners();
  }

  Future<void> addToGoal(String id, double amount) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      goals[index].currentAmount += amount;
      await _storage.saveGoals(goals);
      notifyListeners();
    }
  }

  Future<void> removeFromGoal(String id, double amount) async {
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      goals[index].currentAmount =
          (goals[index].currentAmount - amount).clamp(0.0, double.infinity);
      await _storage.saveGoals(goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    goals.removeWhere((g) => g.id == id);
    await _storage.saveGoals(goals);
    notifyListeners();
  }

  Future<void> addInstallment(InstallmentPurchase purchase) async {
    installments.add(purchase);
    await _storage.saveInstallments(installments);
    notifyListeners();
  }

  Future<void> payInstallment(String id) async {
    final index = installments.indexWhere((i) => i.id == id);
    if (index != -1 && !installments[index].isCompleted) {
      installments[index] = installments[index].copyWith(
        paidInstallments: installments[index].paidInstallments + 1,
      );
      await _storage.saveInstallments(installments);
      notifyListeners();
    }
  }

  Future<void> deleteInstallment(String id) async {
    installments.removeWhere((i) => i.id == id);
    await _storage.saveInstallments(installments);
    notifyListeners();
  }

  Future<void> addMoneyItem(MoneyItem item) async {
    moneyItems.add(item);
    await _storage.saveMoneyItems(moneyItems);
    notifyListeners();
  }

  Future<void> toggleMoneyItem(String id) async {
    final index = moneyItems.indexWhere((e) => e.id == id);
    if (index != -1) {
      moneyItems[index] = moneyItems[index].copyWith(
        isPaidOrReceived: !moneyItems[index].isPaidOrReceived,
      );
      await _storage.saveMoneyItems(moneyItems);
      notifyListeners();
    }
  }

  Future<void> deleteMoneyItem(String id) async {
    moneyItems.removeWhere((e) => e.id == id);
    await _storage.saveMoneyItems(moneyItems);
    notifyListeners();
  }
}

class RecurringInsight {
  final String description;
  final int count;
  final double averageAmount;
  final String frequency;
  final DateTime lastDate;
  final double totalSpent;

  RecurringInsight({
    required this.description,
    required this.count,
    required this.averageAmount,
    required this.frequency,
    required this.lastDate,
    required this.totalSpent,
  });
}