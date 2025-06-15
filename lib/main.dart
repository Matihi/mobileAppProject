import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './widgets/reports_page.dart';
import './widgets/budgets_page.dart';
import './widgets/savings_goals_page.dart';
import './widgets/pie_chart_page.dart';
import './widgets/new_transaction_form.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';
import './helpers/database_helper.dart';
import './widgets/dashboard.dart';
import './models/budget.dart';
import './models/savings_goal.dart';
import './widgets/monthly_summary_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(SavingsGoalAdapter());
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<Budget>('budgets');
    await Hive.openBox<SavingsGoal>('savings_goals');
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: "Quicksand",
            fontWeight: FontWeight.w300,
          ),
        ),
        primarySwatch: Colors.teal,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: "Quicksand",
            fontWeight: FontWeight.w300,
          ),
        ),
        primarySwatch: Colors.teal,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ),
      themeMode: _themeMode,
      home: MyHomePage(
          onThemeChanged: _toggleTheme,
          isDarkMode: _themeMode == ThemeMode.dark),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  final bool isDarkMode;
  MyHomePage({this.onThemeChanged, this.isDarkMode = false});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];
  bool _showChart = false;
  bool get _isWeb => kIsWeb;

  List<Transaction> get _recentTransactions {
    DateTime lastDayOfPrevWeek = DateTime.now().subtract(Duration(days: 6));
    lastDayOfPrevWeek = DateTime(
        lastDayOfPrevWeek.year, lastDayOfPrevWeek.month, lastDayOfPrevWeek.day);
    return _userTransactions.where((element) {
      return element.txnDateTime.isAfter(
        lastDayOfPrevWeek,
      );
    }).toList();
  }

  List<Budget> _budgets = [];
  final List<String> _categories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Salary',
    'Other'
  ];

  List<SavingsGoal> _goals = [];

  @override
  void initState() {
    super.initState();

    _updateUserTransactionsList();
    _fetchBudgets();
    _fetchGoals();
  }

  Future<void> _fetchBudgets() async {
    final budgets = await DatabaseHelper.instance.getAllBudgets();
    print('Loaded budgets:');
    for (var b in budgets) {
      print('Category: \'${b.category}\', Limit: \'${b.limit}\'');
    }
    setState(() {
      _budgets = budgets;
    });
  }

  Future<void> _saveBudget(Budget budget) async {
    await DatabaseHelper.instance.insertBudget(budget);
    _fetchBudgets();
  }

  Future<void> _fetchGoals() async {
    final goals = await DatabaseHelper.instance.getAllSavingsGoals();
    setState(() {
      _goals = goals;
    });
  }

  Future<void> _addGoal(SavingsGoal goal) async {
    await DatabaseHelper.instance.insertSavingsGoal(goal);
    _fetchGoals();
  }

  Future<void> _updateGoal(SavingsGoal goal) async {
    await DatabaseHelper.instance.updateSavingsGoal(goal);
    _fetchGoals();
  }

  void _updateUserTransactionsList() async {
    if (_isWeb) {
      var box = Hive.box<Transaction>('transactions');
      setState(() {
        _userTransactions = box.values.toList();
      });
      return;
    }
    Future<List<Transaction>> res =
        DatabaseHelper.instance.getAllTransactions();
    res.then((txnList) {
      setState(() {
        _userTransactions = txnList;
      });
    });
  }

  void _showChartHandler(bool show) {
    setState(() {
      _showChart = show;
    });
  }

  Future<void> _addNewTransaction(String title, double amount,
      DateTime chosenDate, String category, String type) async {
    final newTxn = Transaction(
      DateTime.now().millisecondsSinceEpoch.toString(),
      title,
      amount,
      chosenDate,
      category,
      type,
    );
    if (_isWeb) {
      var box = Hive.box<Transaction>('transactions');
      await box.add(newTxn);
      _updateUserTransactionsList();
      return;
    }
    int res = await DatabaseHelper.instance.insert(newTxn);
    if (res != 0) {
      _updateUserTransactionsList();
    }
  }

  void _startAddNewTransaction(BuildContext context, {Transaction? txnToEdit}) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0),
            ),
          ),
          child: NewTransactionForm(
            (title, amount, date, category, type) async {
              if (txnToEdit == null) {
                await _addNewTransaction(title, amount, date, category, type);
              } else {
                await _editTransaction(
                    txnToEdit, title, amount, date, category, type);
              }
            },
            initialTransaction: txnToEdit,
          ),
        );
      },
    );
  }

  Future<void> _editTransaction(Transaction oldTxn, String title, double amount,
      DateTime date, String category, String type) async {
    final updatedTxn = Transaction(
      oldTxn.txnId,
      title,
      amount,
      date,
      category,
      type,
    );
    if (_isWeb) {
      var box = Hive.box<Transaction>('transactions');
      final key = box.keys.firstWhere(
        (k) => box.get(k)?.txnId == oldTxn.txnId,
        orElse: () => null,
      );
      if (key != null) {
        await box.put(key, updatedTxn);
        _updateUserTransactionsList();
      }
      return;
    } else {
      await DatabaseHelper.instance.updateTransaction(updatedTxn);
      _updateUserTransactionsList();
    }
  }

  Future<void> _deleteTransaction(String id) async {
    if (_isWeb) {
      var box = Hive.box<Transaction>('transactions');
      final key = box.keys.firstWhere(
        (k) => box.get(k)?.txnId == id,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
        _updateUserTransactionsList();
      }
      return;
    }
    int? txnId = int.tryParse(id);
    if (txnId == null) return;
    int res = await DatabaseHelper.instance.deleteTransactionById(txnId);
    if (res != 0) {
      _updateUserTransactionsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppBar myAppBar = AppBar(
      title: Text(
        'Personal Expenses',
        style: TextStyle(
          fontFamily: "Quicksand",
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
          tooltip: "Add New Transaction",
        ),
        Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Colors.amber),
        Switch(
          value: widget.isDarkMode,
          onChanged: (val) {
            if (widget.onThemeChanged != null) widget.onThemeChanged!(val);
          },
          activeColor: Colors.amber,
          inactiveThumbColor: Colors.grey,
        ),
      ],
    );
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool isLandscape =
        mediaQueryData.orientation == Orientation.landscape;

    final double availableHeight = mediaQueryData.size.height -
        myAppBar.preferredSize.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;

    final double availableWidth = mediaQueryData.size.width -
        mediaQueryData.padding.left -
        mediaQueryData.padding.right;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: myAppBar,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Expense Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "Quicksand",
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.pie_chart),
              title: Text('Spending Pie Chart'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PieChartPage(transactions: _userTransactions),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Reports'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportsPage(transactions: _userTransactions),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Budgets'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BudgetsPage(
                      budgets: _budgets,
                      transactions: _userTransactions,
                      categories: _categories,
                      onSave: _saveBudget,
                    ),
                  ),
                );
                _fetchBudgets();
              },
            ),
            ListTile(
              leading: Icon(Icons.savings),
              title: Text('Savings Goals'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavingsGoalsPage(
                      goals: _goals,
                      onAdd: _addGoal,
                      onUpdate: _updateGoal,
                    ),
                  ),
                );
                _fetchGoals();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MonthlySummaryCard(transactions: _userTransactions),
            Dashboard(transactions: _userTransactions),
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Show Chart",
                    style: TextStyle(
                      fontFamily: "Rubik",
                      fontSize: 16.0,
                      color: Colors.grey[500],
                    ),
                  ),
                  Switch.adaptive(
                    activeColor: Colors.amber[700],
                    value: _showChart,
                    onChanged: (value) => _showChartHandler(value),
                  ),
                ],
              ),
            if (isLandscape)
              _showChart
                  ? myChartContainer(
                      height: availableHeight * 0.8,
                      width: 0.6 * availableWidth)
                  : myTransactionListContainer(
                      height: availableHeight * 0.8,
                      width: 0.6 * availableWidth),
            if (!isLandscape)
              myChartContainer(
                  height: availableHeight * 0.3, width: availableWidth),
            if (!isLandscape)
              myTransactionListContainer(
                  height: availableHeight * 0.7, width: availableWidth),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: kIsWeb
          ? null
          : FloatingActionButton(
              child: Icon(Icons.add),
              tooltip: "Add New Transaction",
              onPressed: () => _startAddNewTransaction(context),
            ),
    );
  }

  Widget myChartContainer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      child: Chart(_recentTransactions),
    );
  }

  Widget myTransactionListContainer(
      {required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      child: TransactionList(
        _userTransactions,
        _deleteTransaction,
        (txn) => _startAddNewTransaction(context, txnToEdit: txn),
      ),
    );
  }
}
