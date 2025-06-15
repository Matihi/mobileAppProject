import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> allTransactions;
  final void Function(String) deleteTransaction;
  final void Function(Transaction) editTransaction; // NEW

  const TransactionList(
      this.allTransactions, this.deleteTransaction, this.editTransaction,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Reverse the list so latest transactions appear first
    final List<Transaction> transactions = List.from(allTransactions.reversed);
    return LayoutBuilder(builder: (ctx, constraints) {
      return transactions.isEmpty
          // No Transactions
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: constraints.maxHeight * 0.1,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "It's lonely out here!",
                      style: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 22.0,
                        fontFamily: "Quicksand",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: constraints.maxHeight * 0.8,
                  child: Image.asset(
                    "assets/images/waiting.png",
                    fit: BoxFit.contain,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
              ],
            )
          // Transactions Present
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                Transaction txn = transactions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3.0, vertical: 3.0),
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                      vertical: 1.0,
                      horizontal: 15.0,
                    ),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Transaction Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Title: ${txn.txnTitle}'),
                                Text(
                                    'Amount: Br${txn.txnAmount.toStringAsFixed(2)}'),
                                Text('Category: ${txn.txnCategory}'),
                                Text('Type: ${txn.txnType}'),
                                Text(
                                    'Date: ${DateFormat('MMMM d, y – h:mm a').format(txn.txnDateTime)}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Container(
                          width: 60.0,
                          height: 40.0,
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.green[700],
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              'Br${txn.txnAmount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0, // Reduced font size
                                color: Colors.white,
                                fontFamily: "Rubik", // Modern font
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          txn.txnTitle,
                          style: const TextStyle(
                            fontFamily: "Rubik", // Modern font
                            fontWeight: FontWeight.w500,
                            fontSize: 17.0,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMMM d, y -')
                              .add_jm()
                              .format(txn.txnDateTime),
                          style: const TextStyle(
                            fontFamily: "Quicksand",
                            fontSize: 13.0,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () => editTransaction(txn),
                              tooltip: "Edit Transaction",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () => deleteTransaction(txn.txnId),
                              tooltip: "Delete Transaction",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
    });
  }
}
