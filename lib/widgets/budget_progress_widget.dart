import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../helpers/database_helper.dart';

class BudgetProgressWidget extends StatelessWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;
  BudgetProgressWidget({required this.budgets, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Only consider this month's transactions
    final thisMonthTxns = transactions.where((txn) =>
        txn.txnDateTime.year == now.year && txn.txnDateTime.month == now.month);
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budgets', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ...budgets.map((budget) {
              final spent = thisMonthTxns
                  .where((txn) =>
                      txn.txnCategory == budget.category &&
                      txn.txnType == 'expense')
                  .fold<double>(0.0, (sum, txn) => sum + txn.txnAmount);
              final percent = budget.limit > 0
                  ? (spent / budget.limit).clamp(0.0, 1.0)
                  : 0.0;
              final overBudget = spent > budget.limit;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            budget.category,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          overBudget
                              ? 'Over by Br ${(spent - budget.limit).toStringAsFixed(2)}'
                              : 'Br ${spent.toStringAsFixed(2)} / Br ${budget.limit.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Budget',
                          onPressed: () async {
                            await DatabaseHelper.instance
                                .deleteBudget(budget.category);
                            if (context.mounted) {
                              (context as Element).markNeedsBuild();
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[300],
                      color: overBudget ? Colors.red : Colors.teal,
                    ),
                  ],
                ),
              );
            }).toList(),
            if (budgets.isEmpty)
              Text('No budgets set. Add one from the Budgets page!',
                  style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
