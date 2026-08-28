import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/credit_card.dart';
import '../models/future_expense.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class FinanceProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Account> accounts = [];
  List<Category> categories = [];
  List<CreditCard> cards = [];
  List<Transaction> transactions = [];
  List<FutureExpense> futureExpenses = [];

  bool isLoading = true;

  double get totalBalance {
    return accounts.fold(0.0, (sum, a) => sum + a.balance);
  }

  double get totalFutureExpenses {
    final now = DateTime.now();
    return futureExpenses
        .where((e) => !e.isPaid && e.dueDate.isAfter(now.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get realAvailableBalance {
    return totalBalance - totalFutureExpenses;
  }

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

  double get monthlyBalance => monthlyIncome - monthlyExpenses;

  double get dailyLimit {
    final remainingDays = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day - DateTime.now().day + 1;
    if (remainingDays <= 0 || realAvailableBalance <= 0) return 0;
    return realAvailableBalance / remainingDays;
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    accounts = await _storage.loadAccounts();
    categories = await _storage.loadCategories();
    cards = await _storage.loadCards();
    transactions = await _storage.loadTransactions();
    futureExpenses = await _storage.loadFutureExpenses();

    if (categories.isEmpty) {
      _createDefaultCategories();
    }
    if (accounts.isEmpty) {
      _createDefaultAccounts();
    }

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
      futureExpenses[index] = FutureExpense(
        id: futureExpenses[index].id,
        description: futureExpenses[index].description,
        amount: futureExpenses[index].amount,
        dueDate: futureExpenses[index].dueDate,
        categoryId: futureExpenses[index].categoryId,
        accountId: futureExpenses[index].accountId,
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
}
