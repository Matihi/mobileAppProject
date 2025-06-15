import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget {
  @HiveField(0)
  late String category;
  @HiveField(1)
  late double limit;

  Budget(this.category, this.limit);

  Budget.fromMap(Map<String, dynamic> map) {
    print('Budget.fromMap: ' + map.toString());
    category = map['category'];
    limit =
        map['limit'] is int ? (map['limit'] as int).toDouble() : map['limit'];
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
    };
  }
}
