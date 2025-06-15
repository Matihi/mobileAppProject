import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 2)
class SavingsGoal {
  @HiveField(0)
  late String name;
  @HiveField(1)
  late double target;
  @HiveField(2)
  late double saved;

  SavingsGoal(this.name, this.target, {this.saved = 0.0});

  SavingsGoal.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    target = map['target'];
    saved = map['saved'] ?? 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'target': target,
      'saved': saved,
    };
  }
}