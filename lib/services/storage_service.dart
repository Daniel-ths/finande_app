import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/credit_card.dart';
import '../models/future_expense.dart';
import '../models/transaction.dart';

class StorageService {
  static const _keyAccounts = 'accounts';
  static const _keyCategories = 'categories';
  static const _keyCards = 'credit_cards';
  static const _keyTransactions = 'transactions';
  static const _keyFutureExpenses = 'future_expenses';

  Future<void> saveAccounts(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final json = accounts.map((e) => e.toJson()).toList();
    await prefs.setString(_keyAccounts, jsonEncode(json));
  }

  Future<List<Account>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyAccounts);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Account.fromJson(e)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final json = categories.map((e) => e.toJson()).toList();
    await prefs.setString(_keyCategories, jsonEncode(json));
  }

  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCategories);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> saveCards(List<CreditCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final json = cards.map((e) => e.toJson()).toList();
    await prefs.setString(_keyCards, jsonEncode(json));
  }

  Future<List<CreditCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCards);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => CreditCard.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final json = transactions.map((e) => e.toJson()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(json));
  }

  Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyTransactions);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<void> saveFutureExpenses(List<FutureExpense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final json = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_keyFutureExpenses, jsonEncode(json));
  }

  Future<List<FutureExpense>> loadFutureExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyFutureExpenses);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => FutureExpense.fromJson(e)).toList();
  }
}
