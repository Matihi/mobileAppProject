import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class Reports extends StatefulWidget {
  final List<Transaction> transactions;

  const Reports({Key? key, required this.transactions}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late DateTime _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _selectedYear = now.year;
  }

  List<Transaction> get _monthlyTxns => widget.transactions.where((txn) =>
      txn.txnDateTime.year == _selectedMonth.year &&
      txn.txnDateTime.month == _selectedMonth.month).toList();

  List<Transaction> get _yearlyTxns => widget.transactions.where((txn) =>
      txn.txnDateTime.year == _selectedYear).toList();

  double _sum(List<Transaction> txns, String type) =>
      txns.where((t) => t.txnType == type).fold(0.0, (a, b) => a + b.txnAmount);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth.month,
                  items: List.generate(12, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
                  )),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, val);
                      });
                    }
                  },
                ),
                DropdownButton<int>(
                  value: _selectedMonth.year,
                  items: List.generate(5, (i) {
                    final year = DateTime.now().year - i;
                    return DropdownMenuItem(value: year, child: Text('$year'));
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = DateTime(val, _selectedMonth.month);
                        _selectedYear = val;
                      });
                    }
                  },
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(5, (i) {
                    final year = DateTime.now().year - i;
                    return DropdownMenuItem(value: year, child: Text('$year'));
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedYear = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Monthly Report (${DateFormat.yMMMM().format(_selectedMonth)})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildSummary(_monthlyTxns),
            const Divider(),
            Text(
              'Yearly Report ($_selectedYear)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildSummary(_yearlyTxns),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(List<Transaction> txns) {
    final income = _sum(txns, 'income');
    final expense = _sum(txns, 'expense');
    final balance = income - expense;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Income:'), Text('Br${income.toStringAsFixed(2)}'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Expense:'), Text('Br${expense.toStringAsFixed(2)}'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Balance:'), Text('Br${balance.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }
}