import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/credit_card.dart';
import '../models/future_expense.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/installment_purchase.dart';

class StorageService {
  static const _keyAccounts = 'accounts';
  static const _keyCategories = 'categories';
  static const _keyCards = 'credit_cards';
  static const _keyTransactions = 'transactions';
  static const _keyFutureExpenses = 'future_expenses';
  static const _keyGoals = 'goals';
  static const _keyInstallments = 'installments';

  Future<void> saveAccounts(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccounts, jsonEncode(accounts.map((e) => e.toJson()).toList()));
  }

  Future<List<Account>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyAccounts);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => Account.fromJson(e)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCategories, jsonEncode(categories.map((e) => e.toJson()).toList()));
  }

  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCategories);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<void> saveCards(List<CreditCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCards, jsonEncode(cards.map((e) => e.toJson()).toList()));
  }

  Future<List<CreditCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCards);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => CreditCard.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTransactions, jsonEncode(transactions.map((e) => e.toJson()).toList()));
  }

  Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyTransactions);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => Transaction.fromJson(e)).toList();
  }

  Future<void> saveFutureExpenses(List<FutureExpense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFutureExpenses, jsonEncode(expenses.map((e) => e.toJson()).toList()));
  }

  Future<List<FutureExpense>> loadFutureExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyFutureExpenses);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => FutureExpense.fromJson(e)).toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGoals, jsonEncode(goals.map((e) => e.toJson()).toList()));
  }

  Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyGoals);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => Goal.fromJson(e)).toList();
  }

  Future<void> saveInstallments(List<InstallmentPurchase> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInstallments, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<List<InstallmentPurchase>> loadInstallments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyInstallments);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => InstallmentPurchase.fromJson(e)).toList();
  }
}
