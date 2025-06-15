import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class NewTransactionForm extends StatefulWidget {
  final void Function(String, double, DateTime, String, String)
      onSubmit; // UPDATED
  final Transaction? initialTransaction; // NEW

  const NewTransactionForm(this.onSubmit, {this.initialTransaction, Key? key})
      : super(key: key);

  @override
  _NewTransactionFormState createState() => _NewTransactionFormState();
}

class _NewTransactionFormState extends State<NewTransactionForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();

  bool _autoValidateToggle = false;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;

  String _selectedCategory = 'Other'; // NEW
  String _selectedType = 'expense'; // NEW

  final List<String> _categories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Salary',
    'Other'
  ];
  final List<String> _types = ['expense', 'income'];

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _titleController.text = widget.initialTransaction!.txnTitle;
      _amountController.text = widget.initialTransaction!.txnAmount.toString();
      _selectedDate = widget.initialTransaction!.txnDateTime;
      _dateController.text = DateFormat('d/M/y').format(_selectedDate);
      _selectedCategory = widget.initialTransaction!.txnCategory;
      _selectedType = widget.initialTransaction!.txnType;
    }
  }

  _NewTransactionFormState() {
    _autoValidateToggle = false;
    _selectedDate = DateTime.now();
    _selectedTime = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(1900, 1),
      lastDate: today,
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.value =
            TextEditingValue(text: DateFormat('d/M/y').format(pickedDate));
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.value = TextEditingValue(
          text: DateFormat.jm().format(
            DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            ),
          ),
        );
      });
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final txnTitle = _titleController.text;
      final txnAmount = double.parse(_amountController.text);
      final txnDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime?.hour ?? 0,
        _selectedTime?.minute ?? 0,
      );
      widget.onSubmit(
        txnTitle,
        txnAmount,
        txnDateTime,
        _selectedCategory,
        _selectedType,
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _autoValidateToggle = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _autoValidateToggle
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const SizedBox(height: 15.0),
            // Category Dropdown + Add Category
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.teal),
                  tooltip: 'Add Category',
                  onPressed: () async {
                    final controller = TextEditingController();
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Add Category'),
                        content: TextField(
                          controller: controller,
                          decoration:
                              InputDecoration(hintText: 'Category name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(controller.text),
                            child: Text('Add'),
                          ),
                        ],
                      ),
                    );
                    if (result != null &&
                        result.trim().isNotEmpty &&
                        !_categories.contains(result.trim())) {
                      setState(() {
                        _categories.add(result.trim());
                        _selectedCategory = result.trim();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _types
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedType = val!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                prefixIcon: Icon(Icons.swap_vert),
              ),
            ),
            const SizedBox(height: 20.0),
            // Title TextField
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                prefixIcon: Icon(Icons.title),
                hintText: "Enter a title",
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return "Title cannot be empty";
                return null;
              },
              focusNode: _titleFocus,
              onFieldSubmitted: (_) =>
                  _fieldFocusChange(context, _titleFocus, _amountFocus),
              controller: _titleController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20.0),
            // Amount TextField
            TextFormField(
              focusNode: _amountFocus,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                prefixIcon: Icon(Icons.local_atm),
                hintText: "Enter the amount",
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return "Please enter valid amount";
                RegExp regex = RegExp(r'^[0-9]+(\.[0-9]+)?');
                if (!regex.hasMatch(value) || double.tryParse(value) == null) {
                  return "Please enter valid amount";
                }
                return null;
              },
              controller: _amountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20.0),
            // Date and Time Textfield
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Date TextField
                Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        focusNode: _dateFocus,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                          ),
                          labelText: 'Date',
                          hintText: 'Date of Transaction',
                          prefixIcon: Icon(Icons.calendar_today),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Please select a date";
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                // Time TextField
                Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _timeController,
                        focusNode: _timeFocus,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                          ),
                          labelText: 'Time',
                          hintText: 'Time of Transaction',
                          prefixIcon: Icon(Icons.schedule),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Please select a time";
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Add Transaction Button
            SizedBox(
              width: double.infinity,
              height: 55.0,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  widget.initialTransaction == null
                      ? 'ADD TRANSACTION'
                      : 'UPDATE TRANSACTION',
                  style: TextStyle(
                    fontFamily: "Rubik",
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16.0,
                  ),
                ),
                onPressed: _onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
