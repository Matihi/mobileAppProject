import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import './savings_goal_widget.dart';
import '../helpers/database_helper.dart';

class SavingsGoalsPage extends StatefulWidget {
  final List<SavingsGoal> goals;
  final Function(SavingsGoal) onAdd;
  final Function(SavingsGoal) onUpdate;

  SavingsGoalsPage(
      {required this.goals, required this.onAdd, required this.onUpdate});

  @override
  _SavingsGoalsPageState createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends State<SavingsGoalsPage> {
  late List<SavingsGoal> _goals;

  @override
  void initState() {
    super.initState();
    _goals = widget.goals;
  }

  Future<void> _handleAdd(SavingsGoal goal) async {
    await widget.onAdd(goal);
    final latestGoals = await DatabaseHelper.instance.getAllSavingsGoals();
    setState(() {
      _goals = latestGoals;
    });
  }

  Future<void> _handleUpdate(SavingsGoal goal) async {
    await widget.onUpdate(goal);
    final latestGoals = await DatabaseHelper.instance.getAllSavingsGoals();
    setState(() {
      _goals = latestGoals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Savings Goals')),
      body: SavingsGoalWidget(
          goals: _goals, onAdd: _handleAdd, onUpdate: _handleUpdate),
    );
  }
}
