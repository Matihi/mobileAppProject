import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class SpendingPieChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SpendingPieChart({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    final Map<String, double> categoryTotals = {};
    for (var txn in transactions) {
      if (txn.txnType == 'expense') {
        final double prev = categoryTotals[txn.txnCategory] ?? 0.0;
        final double amount = txn.txnAmount;
        categoryTotals[txn.txnCategory] = prev + amount;
      }
    }

    final total = categoryTotals.values.fold<double>(0.0, (a, b) => a + b);

    if (categoryTotals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No expenses to show in pie chart.'),
      );
    }

    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.brown
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Spending Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.mapIndexed((i, entry) {
                    final percent = (entry.value / total * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      color: colors[i % colors.length],
                      value: entry.value,
                      title: '${entry.key}\n$percent%',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


extension<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int, E) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}