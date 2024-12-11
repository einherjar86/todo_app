import 'package:flutter/material.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/save_todo.dart';
import 'package:todo_app/utility.dart';

class DetailPage extends StatefulWidget {
  final Todo todo;

  DetailPage({required this.todo});
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todo.title,
          style: TextStyle(color: Color(0xFFFFFFFE)),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          TextButton(
            child: Text(
              "編集",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SaveTodo(todo: widget.todo)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.todo.getSelectedDaysString().isNotEmpty
                ? Text(
                    widget.todo.getSelectedDaysString(),
                    style: TextStyle(
                      fontSize: 24,
                      decoration: TextDecoration.underline, // 下線付き
                      color: HexColor('333333'),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(height: 20),
            Text(
              widget.todo!.detail,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
