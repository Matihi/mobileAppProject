import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../helpers/database_helper.dart';

class SavingsGoalWidget extends StatelessWidget {
  final List<SavingsGoal> goals;
  final void Function(SavingsGoal) onAdd;
  final void Function(SavingsGoal) onUpdate;

  const SavingsGoalWidget({
    Key? key,
    required this.goals,
    required this.onAdd,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Savings Goals',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...goals.map((goal) => ListTile(
                  leading: Text(goal.name),
                  subtitle: Text(
                      'Target: Br${goal.target.toStringAsFixed(2)} | Saved: Br${goal.saved.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Goal',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final addController = TextEditingController();
                              return AlertDialog(
                                title: Text('Add to ${goal.name}'),
                                content: TextField(
                                  controller: addController,
                                  decoration: const InputDecoration(
                                      labelText: 'Amount to add'),
                                  keyboardType: TextInputType.number,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      final addAmount =
                                          double.tryParse(addController.text) ??
                                              0.0;
                                      if (addAmount > 0) {
                                        onUpdate(SavingsGoal(
                                            goal.name, goal.target,
                                            saved: goal.saved + addAmount));
                                      }
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Goal',
                        onPressed: () async {
                          await DatabaseHelper.instance
                              .deleteSavingsGoal(goal.name);
                          if (context.mounted) {
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ],
                  ),
                )),
            const Divider(),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
            ),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(labelText: 'Target Amount'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    targetController.text.isNotEmpty) {
                  onAdd(SavingsGoal(nameController.text,
                      double.parse(targetController.text)));
                  nameController.clear();
                  targetController.clear();
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
