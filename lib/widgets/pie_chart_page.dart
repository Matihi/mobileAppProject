import 'package:flutter/material.dart';
import '../models/transaction.dart';
import './spending_pie_chart.dart';

class PieChartPage extends StatelessWidget {
  final List<Transaction> transactions;
  PieChartPage({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spending Pie Chart')),
      body: SpendingPieChart(transactions: transactions),
    );
  }
}
