import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import './budget_setter.dart';
import './budget_alert.dart';
import './budget_progress_widget.dart';
import '../helpers/database_helper.dart';

class BudgetsPage extends StatefulWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;
  final List<String> categories;
  final Function(Budget) onSave;

  BudgetsPage({
    required this.budgets,
    required this.transactions,
    required this.categories,
    required this.onSave,
  });

  @override
  _BudgetsPageState createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  late List<Budget> _budgets;

  @override
  void initState() {
    super.initState();
    _budgets = widget.budgets;
  }

  void _handleSave(Budget budget) async {
    await widget.onSave(budget);
    // Fetch latest budgets from database after saving
    final latestBudgets = await DatabaseHelper.instance.getAllBudgets();
    setState(() {
      _budgets = latestBudgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BudgetProgressWidget(
                budgets: _budgets, transactions: widget.transactions),
            BudgetAlert(budgets: _budgets, transactions: widget.transactions),
            BudgetSetter(categories: widget.categories, onSave: _handleSave),
          ],
        ),
      ),
    );
  }
}
