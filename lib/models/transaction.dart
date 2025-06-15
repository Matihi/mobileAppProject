import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  late String _id;
  @HiveField(1)
  late String _title;
  @HiveField(2)
  late double _amount;
  @HiveField(3)
  late DateTime _date;
  @HiveField(4)
  late String _category; // NEW
  @HiveField(5)
  late String _type; // NEW: 'income' or 'expense'

  String get txnId => _id;
  String get txnTitle => _title;
  double get txnAmount => _amount;
  DateTime get txnDateTime => _date;
  String get txnCategory => _category; // NEW
  String get txnType => _type; // NEW

  Transaction(
    this._id,
    this._title,
    this._amount,
    this._date,
    this._category, // NEW
    this._type, // NEW
  );

  Transaction.fromMap(Map<String, dynamic> map) {
    _id = map['id'].toString();
    _title = map['title'];
    _amount = map['amount'];
    _date = DateTime.parse(map['date']);
    _category = map['category'] ?? 'Other'; // NEW
    _type = map['type'] ?? 'expense'; // NEW
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': int.tryParse(_id),
      'title': _title,
      'amount': _amount,
      'date': _date.toIso8601String(),
      'category': _category, // NEW
      'type': _type, // NEW
    };
    return map;
  }
}