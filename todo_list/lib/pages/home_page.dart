import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskModel> tasksList = [];

  void saveOnLocalStorage() {
    final taskData = tasksList.map((task) => task.toJson()).toList();
    sharedPreferences?.setStringList('tasks', taskData);
  }

  void createTask({required TaskModel task}) {
    setState(() {
      tasksList.add(task);
      saveOnLocalStorage();
    });
  }

  void readTasks() {
    setState(() {
      final taskData = sharedPreferences?.getStringList('tasks') ?? [];
      tasksList =
          taskData.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
    });
  }

  void updateTask({required String taskId, required TaskModel updatedTask}) {
    final taskIndex = tasksList.indexWhere((task) => task.id == taskId);
    setState(() {
      tasksList[taskIndex] = updatedTask;
      saveOnLocalStorage();
    });
  }

  void deleteTask({required String taskId}) {
    setState(() {
      tasksList.removeWhere((task) => task.id == taskId);
      saveOnLocalStorage();
    });
  }

  final TextEditingController taskTextEditingController =
      TextEditingController();

  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  void initPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    readTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child:
            tasksList.isNotEmpty
                ? Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ListView.builder(
                          itemCount: tasksList.length,
                          itemBuilder: (context, index) {
                            final TaskModel task = tasksList[index];
                            return ListTile(
                              leading: Transform.scale(
                                scale: 2.0,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  value: task.isCompleted,
                                  onChanged: (isChecked) {
                                    final TaskModel updatedTask = task;
                                    updatedTask.isCompleted = isChecked!;
                                    updateTask(
                                      taskId: updatedTask.id,
                                      updatedTask: updatedTask,
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  color:
                                      task.isCompleted
                                          ? Colors.grey
                                          : Colors.black,
                                  decoration:
                                      task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                  fontSize: 20,
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  deleteTask(taskId: task.id);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 30.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
                : const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Text(
                      'Tidak ada tugas yang ditambahkan, tekan tombol',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Tambahkan Tugas'),
                content: TextField(
                  controller: taskTextEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Ketik Tugas Anda',
                  ),
                  maxLines: 2,
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (taskTextEditingController.text.isNotEmpty) {
                        final TaskModel newTask = TaskModel(
                          id: DateTime.now().toString(),
                          title: taskTextEditingController.text,
                        );

                        createTask(task: newTask);
                        taskTextEditingController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
