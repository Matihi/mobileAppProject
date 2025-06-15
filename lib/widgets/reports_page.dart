import 'package:flutter/material.dart';
import '../models/transaction.dart';
import './reports.dart';

class ReportsPage extends StatelessWidget {
  final List<Transaction> transactions;
  ReportsPage({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Reports(transactions: transactions),
    );
  }
}
