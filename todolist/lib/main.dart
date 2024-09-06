import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late TextEditingController _texteditController;
  late TextEditingController _descriptionController;

  final List<Map<String, String>> _myList = [];

  @override
  void initState() {
    super.initState();
    _texteditController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void addTodoHandle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new task"),
          content: SizedBox(
            width: 120,
            height: 140,
            child: Column(
              children: [
                TextField(
                  controller: _texteditController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Input your task"),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _myList.add({
                    'title': _texteditController.text,
                    'description': _descriptionController.text
                  });
                });
                _texteditController.text = "";
                _descriptionController.text = "";
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _myList.isEmpty
          ? const Center(child: Text('No tasks available!'))
          : ListView.builder(
              itemCount: _myList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_myList[index]['title']!),
                  subtitle: Text(_myList[index]['description']!),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTodoHandle(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
