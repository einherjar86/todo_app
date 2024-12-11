import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/utility.dart';

class SaveTodo extends StatefulWidget {
  final Todo? todo;

  SaveTodo({this.todo});
  @override
  _SaveTodoState createState() => _SaveTodoState();
}

class _SaveTodoState extends State<SaveTodo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final List<String> weekdays = ["日", "月", "火", "水", "木", "金", "土"];
  List<bool> selectedDays = List.generate(7, (_) => false);
  DateTime? selectedDate = null;
  bool isDone = false;

  String get selectedWeekdaysText {
    if (selectedDate != null) {
      return "${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日";
    } else {
      if (selectedDays.every((e) => e)) {
        // 127 はすべての曜日 (1111111)
        return "毎日";
      }
      List<String> selectedWeekdays = [];
      for (int i = 0; i < selectedDays.length; i++) {
        if (selectedDays[i]) {
          selectedWeekdays.add(weekdays[i]);
        }
      }
      if (selectedWeekdays.isNotEmpty) {
        return "毎週 ${selectedWeekdays.join('、')}";
      }
      return ''; // 曜日が選ばれていない場合
    }
  }

  @override
  void initState() {
    super.initState();

    // 編集モードの場合、既存データを入力欄にセット
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _detailController.text = widget.todo!.detail;
      isDone = widget.todo!.isDone;
      selectedDays = convertIntToList(widget.todo!.selectedDays);
      selectedDate = widget.todo!.date;
    }
  }

  int convertListToInt(List<bool> selectedDays) {
    int result = 0;
    // 日曜日が0、月曜日が1、... 土曜日が6
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        // 対応するビットを1に設定
        result |= (1 << i);
      }
    }
    return result;
  }

  List<bool> convertIntToList(int selectedDays) {
    List<bool> result = List.filled(7, false);
    // 日曜日が0、月曜日が1、... 土曜日が6
    for (int i = 0; i < 7; i++) {
      // 対応するビットが1ならば、曜日を選択されたとする
      if ((selectedDays & (1 << i)) != 0) {
        result[i] = true;
      }
    }
    return result;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      var newTodo = Todo(
          title: _titleController.text,
          detail: _detailController.text,
          doneDate: isDone ? widget.todo?.doneDate ?? DateTime.now() : null,
          date: selectedDate,
          selectedDays: convertListToInt(selectedDays));
      if (widget.todo != null) {
        Navigator.pop(context);
      }
      Navigator.pop(context, newTodo);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        selectedDate;
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDays = List.generate(7, (_) => false);
      });
    }
  }

  void _onDaySelected(int index) {
    setState(() {
      selectedDays[index] = !selectedDays[index];
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todo != null ? '編集' : '新規登録',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          TextButton(
            child: Text(
              "保存",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              widget.todo != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: Text('完了',
                              style: TextStyle(
                                  fontSize: 24, color: HexColor('333333'))),
                        ),
                        Switch(
                          value: isDone,
                          onChanged: (value) {
                            setState(() {
                              isDone = value; // トグルボタンの状態を更新
                            });
                          },
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 選択された曜日の表示
                  Text(
                    selectedWeekdaysText,
                    style: TextStyle(fontSize: 18),
                  ),
                  // 右寄せのカレンダーアイコンボタン
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(weekdays.length, (index) {
                  final day = weekdays[index];

                  // 曜日ごとの色を設定
                  Color dayColor;
                  if (day == "土") {
                    dayColor = Colors.blue; // 土曜: 水色
                  } else if (day == "日") {
                    dayColor = Colors.red; // 日曜: 赤色
                  } else {
                    dayColor = HexColor('333333'); // 平日: 黒色
                  }

                  return GestureDetector(
                    onTap: () async {
                      _onDaySelected(index);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: selectedDays[index]
                            ? Border.all(
                                color: Colors.deepPurpleAccent, width: 2)
                            : null,
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: selectedDays[index]
                              ? Colors.deepPurpleAccent
                              : dayColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください。';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                  controller: _detailController,
                  decoration: InputDecoration(
                    labelText: '詳細',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5),
            ],
          ),
        ),
      ),
    );
  }
}
