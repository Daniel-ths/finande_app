import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();

    if (_selectedCategoryId == null && provider.categories.isNotEmpty) {
      _selectedCategoryId = provider.categories.first.id;
    }
    if (_selectedAccountId == null && provider.accounts.isNotEmpty) {
      _selectedAccountId = provider.accounts.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_type == TransactionType.income ? 'Nova Receita' : 'Nova Despesa'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Despesa'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Receita'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o valor';
                final amount = double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount <= 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Informe a descrição';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: provider.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text('${cat.icon} ${cat.name}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              validator: (value) => value == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccountId,
              decoration: const InputDecoration(
                labelText: 'Conta',
                border: OutlineInputBorder(),
              ),
              items: provider.accounts.map((acc) {
                return DropdownMenuItem(
                  value: acc.id,
                  child: Text(acc.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAccountId = value),
              validator: (value) => value == null ? 'Selecione uma conta' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => _save(provider),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Salvar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _save(FinanceProvider provider) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedAccountId == null) return;

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));

    final transaction = Transaction(
      description: _descriptionController.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    provider.addTransaction(transaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_type == TransactionType.income ? 'Receita adicionada!' : 'Despesa adicionada!'),
      ),
    );

    Navigator.pop(context);
  }
}
