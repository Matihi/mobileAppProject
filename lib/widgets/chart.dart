import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './chart_bar.dart';
import '../models/transaction.dart';

class Chart extends StatelessWidget {
  final List<Transaction> recentTransactions;

  const Chart(this.recentTransactions, {Key? key}) : super(key: key);

  List<Map<String, Object>> get groupedTransactionValues {
    final today = DateTime.now();
    List<double> weekSums = List<double>.filled(7, 0);
    double totalSpending = 0.0;

    for (Transaction txn in recentTransactions) {
      int weekdayIndex = txn.txnDateTime.weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < 7) {
        weekSums[weekdayIndex] += txn.txnAmount;
        totalSpending += txn.txnAmount;
      }
    }

    return List.generate(7, (index) {
      final dayOfPastWeek = today.subtract(
        Duration(days: index),
      );
      return {
        'day': DateFormat('E').format(dayOfPastWeek)[0],
        'amount': weekSums[dayOfPastWeek.weekday - 1],
        'total': totalSpending,
      };
    }).reversed.toList();
  }

  double get totalSpending {
    return recentTransactions.fold(0.0, (sum, txn) => sum + txn.txnAmount);
  }

  @override
  Widget build(BuildContext context) {
    final total = totalSpending;
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: groupedTransactionValues.map((value) {
            final String day = value['day'] as String;
            final double amount = value['amount'] as double;
            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                day,
                amount,
                total == 0.0 ? 0.0 : amount / total,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
