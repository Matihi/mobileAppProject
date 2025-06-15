import 'package:flutter/material.dart';
import '../models/transaction.dart';

class Dashboard extends StatelessWidget {
  final List<Transaction> transactions;

  const Dashboard({Key? key, required this.transactions}) : super(key: key);

  double get totalIncome => transactions
      .where((txn) => txn.txnType == 'income')
      .fold(0.0, (sum, txn) => sum + txn.txnAmount);

  double get totalExpense => transactions
      .where((txn) => txn.txnType == 'expense')
      .fold(0.0, (sum, txn) => sum + txn.txnAmount);

  double get balance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem('Income', totalIncome, Colors.green),
            _buildItem('Expense', totalExpense, Colors.red),
            _buildItem('Balance', balance, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, double value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Br${value.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
        ),
      ],
    );
  }
}