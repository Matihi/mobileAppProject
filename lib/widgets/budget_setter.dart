import 'package:flutter/material.dart';
import '../models/budget.dart';

class BudgetSetter extends StatefulWidget {
  final List<String> categories;
  final void Function(Budget) onSave;

  const BudgetSetter({Key? key, required this.categories, required this.onSave}) : super(key: key);

  @override
  State<BudgetSetter> createState() => _BudgetSetterState();
}

class _BudgetSetterState extends State<BudgetSetter> {
  String? _selectedCategory;
  final _limitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: widget.categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _limitController,
              decoration: const InputDecoration(labelText: 'Monthly Limit'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_selectedCategory != null && _limitController.text.isNotEmpty) {
                  widget.onSave(Budget(_selectedCategory!, double.parse(_limitController.text)));
                  _limitController.clear();
                  setState(() => _selectedCategory = null);
                }
              },
              child: const Text('Set Budget'),
            ),
          ],
        ),
      ),
    );
  }
}