import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/transaction.dart';

class BudgetAlert extends StatelessWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;

  const BudgetAlert({Key? key, required this.budgets, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> alerts = [];
    for (var budget in budgets) {
      double spent = transactions
          .where((txn) => txn.txnCategory == budget.category && txn.txnType == 'expense')
          .fold(0.0, (sum, txn) => sum + txn.txnAmount);
      if (spent > budget.limit) {
        alerts.add(
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(
              'Budget exceeded for ${budget.category}!',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Limit: Br${budget.limit.toStringAsFixed(2)}, Spent: Br${spent.toStringAsFixed(2)}'),
          ),
        );
      }
    }
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Colors.red[50],
      margin: const EdgeInsets.all(12),
      child: Column(children: alerts),
    );
  }
}