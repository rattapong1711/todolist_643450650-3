import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import FontAwesome

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "your-api-key",
            authDomain: "your-auth-domain",
            projectId: "your-project-id",
            storageBucket: "your-storage-bucket",
            messagingSenderId: "your-messaging-sender-id",
            appId: "your-app-id",
            measurementId: "your-measurement-id"));
  } else {
    await Firebase.initializeApp();
  }
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

  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks'); // Firestore collection

  @override
  void initState() {
    super.initState();
    _texteditController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _texteditController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Add task to Firestore
  Future<void> addTodoHandle(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new task"),
          content: SizedBox(
            width: 300, // Increase the width for better visibility
            height: 200, // Increase the height for better visibility
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
              onPressed: () async {
                if (_texteditController.text.isEmpty) {
                  // Show a snackbar if the task title is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task title cannot be empty!'),
                    ),
                  );
                  return;
                }
                await tasksCollection.add({
                  'title': _texteditController.text,
                  'description': _descriptionController.text,
                  'completed': false,
                });
                _texteditController.clear(); // Clear the text field
                _descriptionController.clear(); // Clear the text field
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Edit task in Firestore
  Future<void> editTodoHandle(
      String taskId, Map<String, dynamic> taskData, BuildContext context) async {
    _texteditController.text = taskData['title'];
    _descriptionController.text = taskData['description'];
    bool completed = taskData['completed'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit task"),
          content: SizedBox(
            width: 300, // Increase the width for better visibility
            height: 250, // Increase the height for better visibility
            child: Column(
              children: [
                TextField(
                  controller: _texteditController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Edit your task"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Description"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: completed,
                      onChanged: (value) {
                        setState(() {
                          completed = value!;
                        });
                      },
                    ),
                    const Text("Completed"),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_texteditController.text.isEmpty) {
                  // Show a snackbar if the task title is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task title cannot be empty!'),
                    ),
                  );
                  return;
                }
                await tasksCollection.doc(taskId).update({
                  'title': _texteditController.text,
                  'description': _descriptionController.text,
                  'completed': completed,
                });
                _texteditController.clear(); // Clear the text field
                _descriptionController.clear(); // Clear the text field
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Delete task from Firestore
  Future<void> deleteTodoHandle(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder(
        stream: tasksCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs;

          return tasks.isEmpty
              ? const Center(child: Text('No tasks available!'))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    var taskData = task.data() as Map<String, dynamic>;
                    var taskId = task.id;

                    return ListTile(
                      leading: Checkbox(
                        value: taskData['completed'],
                        onChanged: (bool? value) async {
                          await tasksCollection
                              .doc(taskId)
                              .update({'completed': value!});
                        },
                      ),
                      title: Text(
                        taskData['title']!,
                        style: TextStyle(
                            decoration: taskData['completed']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none),
                      ),
                      subtitle: Text(taskData['description']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editTodoHandle(taskId, taskData, context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteTodoHandle(taskId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
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
