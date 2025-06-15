import 'package:flutter/material.dart';
import '../models/transaction.dart';

class MonthlySummaryCard extends StatelessWidget {
  final List<Transaction> transactions;
  MonthlySummaryCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonthTxns = transactions.where((txn) =>
        txn.txnDateTime.year == now.year && txn.txnDateTime.month == now.month);
    double totalIncome = 0;
    double totalExpense = 0;
    for (var txn in thisMonthTxns) {
      if (txn.txnType.toLowerCase() == 'income') {
        totalIncome += txn.txnAmount;
      } else {
        totalExpense += txn.txnAmount;
      }
    }
    double savings = totalIncome - totalExpense;
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Summary',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Income:', style: TextStyle(color: Colors.green)),
                Text('Br ${totalIncome.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses:', style: TextStyle(color: Colors.red)),
                Text('Br ${totalExpense.toStringAsFixed(2)}'),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Savings:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Br ${savings.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
