import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/detail.dart';
import 'package:todo_app/save_todo.dart';
import 'package:todo_app/utility.dart';
import 'todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todo_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ToDoアプリ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _todoBox = Hive.box<Todo>('todo_box');
  List<Todo> items = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    setState(() {
      items = _todoBox.values.toList();
    });
  }

  void _saveToDo(Todo todo, int index) async {
    if (index != -1) {
      await _todoBox.putAt(index, todo);
    } else {
      await _todoBox.add(todo);
    }
    _loadTodos();
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(''),
          content: Text('本当に削除しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('キャンセル', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _todoBox.deleteAt(index);
                });
                _loadTodos();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('削除', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _pushPage() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SaveTodo()));
    if (result != null) {
      _saveToDo(result, -1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登録しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _pushDetailPage(int index) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPage(todo: items[index])));
    if (result != null) {
      _saveToDo(result, index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登録しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'タスク一覧',
          style: TextStyle(color: Color(0xFFFFFFFE)),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final todo = items[index];
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: HexColor('e2e2e2')),
                  ),
                ),
                child: ListTile(
                  leading: todo.isDone
                      ? Icon(Icons.check, color: Colors.green)
                      : SizedBox(width: 20),
                  title: Text(
                    todo.title,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    todo.getSelectedDaysString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete_forever,
                            color: HexColor('757575')),
                        onPressed: () {
                          _deleteItem(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () => _pushDetailPage(index),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _pushPage();
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
