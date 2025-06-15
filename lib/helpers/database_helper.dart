import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart' as txn;
import '../models/budget.dart';
import '../models/savings_goal.dart';

// database table and column names
final String tableTransactions = 'transactions';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnAmount = 'amount';
final String columnDate = 'date';
final String columnCategory = 'category';
final String columnType = 'type';
final String tableBudgets = 'budgets';
final String columnBudgetCategory = 'category';
final String columnBudgetLimit = 'limit';
final String tableSavingsGoals = 'savings_goals';
final String columnGoalName = 'name';
final String columnGoalTarget = 'target';
final String columnGoalSaved = 'saved';

// singleton class to manage the database
class DatabaseHelper {
  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  // actual database filename that is saved in the docs directory.
  static final _databaseName = "transactionsDB.db";

  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // open the database
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // On web, do not use sqflite or path_provider
      throw UnsupportedError('sqflite is not supported on the web.');
    }
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $tableTransactions (
          $columnId INTEGER PRIMARY KEY,
          $columnTitle TEXT NOT NULL,
          $columnAmount REAL NOT NULL,
          $columnDate TEXT NOT NULL,
          $columnCategory TEXT NOT NULL, -- NEW
          $columnType TEXT NOT NULL -- NEW
        )
        ''');
    await db.execute('''
        CREATE TABLE $tableBudgets (
          $columnBudgetCategory TEXT PRIMARY KEY,
          $columnBudgetLimit REAL NOT NULL
        )
        ''');
    await db.execute('''
        CREATE TABLE $tableSavingsGoals (
          $columnGoalName TEXT PRIMARY KEY,
          $columnGoalTarget REAL NOT NULL,
          $columnGoalSaved REAL NOT NULL
        )
        ''');
  }

  // Database helper methods:

  Future<int> insert(txn.Transaction element) async {
    Database db = await database;
    int id = await db.insert(tableTransactions, element.toMap());
    return id;
  }

  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    if (kIsWeb) {
      var box = Hive.box<SavingsGoal>('savings_goals');
      await box.put(goal.name, goal);
      return 1;
    }
    Database db = await database;
    return await db.insert(tableSavingsGoals, goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    if (kIsWeb) {
      var box = Hive.box<SavingsGoal>('savings_goals');
      return box.values.toList();
    }
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(tableSavingsGoals);
    return res.map((e) => SavingsGoal.fromMap(e)).toList();
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    if (kIsWeb) {
      var box = Hive.box<SavingsGoal>('savings_goals');
      await box.put(goal.name, goal);
      return 1;
    }
    Database db = await database;
    return await db.update(
      tableSavingsGoals,
      goal.toMap(),
      where: '$columnGoalName = ?',
      whereArgs: [goal.name],
    );
  }

  Future<int> insertBudget(Budget budget) async {
    if (kIsWeb) {
      var box = Hive.box<Budget>('budgets');
      await box.put(budget.category, budget);
      return 1;
    }
    print(
        'Inserting budget: category=${budget.category}, limit=${budget.limit}');
    Database db = await database;
    return await db.insert(tableBudgets, budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Budget>> getAllBudgets() async {
    if (kIsWeb) {
      var box = Hive.box<Budget>('budgets');
      return box.values.toList();
    }
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(tableBudgets);
    return res.map((e) => Budget.fromMap(e)).toList();
  }

  Future<int> updateBudget(Budget budget) async {
    Database db = await database;
    return await db.update(
      tableBudgets,
      budget.toMap(),
      where: '$columnBudgetCategory = ?',
      whereArgs: [budget.category],
    );
  }

  Future<txn.Transaction?> getTransactionById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(tableTransactions,
        columns: [columnId, columnTitle, columnAmount, columnDate],
        where: '$columnId = ?',
        whereArgs: [id]);

    if (res.isNotEmpty) {
      return txn.Transaction.fromMap(res.first);
    }
    return null;
  }

  Future<List<txn.Transaction>> getAllTransactions() async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(tableTransactions,
        columns: [
          columnId,
          columnTitle,
          columnAmount,
          columnDate,
          columnCategory,
          columnType
        ]);
    List<txn.Transaction> list =
        res.map((e) => txn.Transaction.fromMap(e)).toList();
    return list;
  }

  Future<int> deleteTransactionById(int id) async {
    Database db = await database;
    int res =
        await db.delete(tableTransactions, where: "id = ?", whereArgs: [id]);
    return res;
  }

  Future<int> deleteAllTransactions() async {
    Database db = await database;
    int res = await db.delete(tableTransactions, where: '1');
    return res;
  }

  Future<int> updateTransaction(txn.Transaction element) async {
    Database db = await database;
    return await db.update(
      tableTransactions,
      element.toMap(),
      where: '$columnId = ?',
      whereArgs: [int.tryParse(element.txnId)],
    );
  }

  Future<int> deleteBudget(String category) async {
    if (kIsWeb) {
      var box = Hive.box<Budget>('budgets');
      await box.delete(category);
      return 1;
    }
    Database db = await database;
    return await db.delete(tableBudgets,
        where: '$columnBudgetCategory = ?', whereArgs: [category]);
  }

  Future<int> deleteSavingsGoal(String name) async {
    if (kIsWeb) {
      var box = Hive.box<SavingsGoal>('savings_goals');
      await box.delete(name);
      return 1;
    }
    Database db = await database;
    return await db.delete(tableSavingsGoals,
        where: '$columnGoalName = ?', whereArgs: [name]);
  }
}
