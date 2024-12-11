import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String title;

  @HiveField(1)
  String detail;

  @HiveField(2)
  DateTime? doneDate;

  @HiveField(3)
  DateTime? date;

  @HiveField(4)
  int selectedDays;

  Todo(
      {required this.title,
      required this.detail,
      required this.doneDate,
      required this.date,
      required this.selectedDays});

  // 曜日が選択されているかを確認するヘルパーメソッド
  bool isDaySelected(int dayIndex) {
    return (selectedDays & (1 << dayIndex)) != 0;
  }

  bool get isDone {
    return this.doneDate != null;
  }

  // 曜日を文字列で取得するメソッド
  String getSelectedDaysString() {
    if (date != null) {
      return "${date!.year}年${date!.month}月${date!.day}日";
    } else {
      if (selectedDays == 127) {
        // 127 はすべての曜日 (1111111)
        return "毎日";
      }
      List<String> days = ["日", "月", "火", "水", "木", "金", "土"];
      List<String> selectedDaysString = [];
      for (int i = 0; i < 7; i++) {
        if (isDaySelected(i)) {
          selectedDaysString.add(days[i]);
        }
      }
      return selectedDaysString.isNotEmpty ? selectedDaysString.join("、") : "";
    }
  }
}
