import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/task_model.dart';
import '../../logic/blocs/task/task_bloc.dart';
import '../../logic/blocs/task/task_event.dart' as task_event;
import '../../services/sqlite.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  final DatabaseHelper databaseHelper;
  TaskListScreen({required this.databaseHelper});

  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final int _limit = 10;
  int _currentPage = 0;
  late int _totalTasks;
  late List<Task> _tasks;
  late Future<void> _initDatabase;

  @override
  void initState() {
    super.initState();
    _totalTasks = 0;
    _tasks = [];
    _fetchTasks();
    _initDatabase = _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await widget.databaseHelper.initDatabase();
  }

  void _fetchTasks() {
    final int skip = _currentPage * _limit;
    BlocProvider.of<TaskBloc>(context).add(LoadTasks(limit: _limit, skip: skip));
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
    _fetchTasks();
  }

  Future<Map<String, dynamic>?> _showEditTaskDialog(Task task) async {
    String? todo = task.todo;
    bool completed = task.completed;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Edit Task'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => todo = value,
                    controller: TextEditingController(text: task.todo),
                    decoration: const InputDecoration(hintText: 'Enter task description'),
                  ),
                  CheckboxListTile(
                    value: completed,
                    onChanged: (value) {
                      setState(() {
                        completed = value ?? false;
                      });
                    },
                    title: const Text('Completed'),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel',style: TextStyle(color: Colors.deepPurpleAccent,fontSize: 16),),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop({'todo': todo, 'completed': completed}),
                      child: const Text('Update',style: TextStyle(color: Colors.deepPurpleAccent,fontSize: 16),),
                    ),
                  ],
                ),

              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addTask(String todo, int userId) async {
    BlocProvider.of<TaskBloc>(context).add(AddTask(todo: todo, userId: userId));
  }

  Future<void> _updateTask(Task task) async {
    final updatedTask = await _showEditTaskDialog(task);
    if (updatedTask != null) {
      BlocProvider.of<TaskBloc>(context).add(UpdateTask(
        id: task.id,
        todo: updatedTask['todo'],
        completed: updatedTask['completed'],
      ));
    }
  }

  Future<void> _deleteTask(int id) async {
    BlocProvider.of<TaskBloc>(context).add(DeleteTask(id: id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             SizedBox(
               height: 250,
               child: DrawerHeader(
                 margin : const EdgeInsets.only(bottom: 20.0),
                decoration: const BoxDecoration(color: Colors.deepPurpleAccent),
                child: Column(
                  children: [
                    const Text('Task Manager App',style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),),
                    Image.asset('assets/tasks.webp',width: 140,),
                  ],
                ),
                           ),
             ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
               // BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          print(state);
          if (state is TaskLoaded) {
            setState(() {
              _totalTasks = state.totalTasks;
              _tasks = state.tasks;
            });
          }
        },
        child: Column(
          children: [
            Expanded(
              child: _buildTaskList(_tasks),
            ),
            _buildPaginationControls(_totalTasks),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          final todo = await _showAddTaskDialog();
          if (todo != null) {
            final SharedPreferences preferences = await SharedPreferences.getInstance();
            final int? userId = preferences.getInt('userId');
            if (userId != null) {
              _addTask(todo, userId);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 0.5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              title: Text(task.todo),
              subtitle:  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("status : "),
                  Icon(task.completed ? Icons.check_circle:Icons.access_time_rounded,color: task.completed ? Colors.green:Colors.grey,),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _updateTask(task),
                    color: Colors.orange,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(task.id),
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls(int totalTasks) {
    final int totalPages = (totalTasks / _limit).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon:  Icon(Icons.arrow_back_ios,color: _currentPage > 0 ? Colors.deepPurpleAccent : Colors.grey,),
          onPressed: _currentPage > 0 ? () => _onPageChanged(_currentPage - 1) : null,
        ),
        Text('Page ${_currentPage + 1} of $totalPages'),
        IconButton(
          icon:  Icon(Icons.arrow_forward_ios,color: (_currentPage < totalPages - 1) ? Colors.deepPurpleAccent:Colors.grey),
          onPressed: (_currentPage < totalPages - 1) ? () => _onPageChanged(_currentPage + 1) : null,
        ),
      ],
    );
  }

  Future<String?> _showAddTaskDialog() async {
    String? todo;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: const Text('Add Task')),
          content: TextField(
            onChanged: (value) => todo = value,
            decoration: const InputDecoration(hintText: 'Enter task description'),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel',style: TextStyle(color: Colors.deepPurpleAccent,fontSize: 16),),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(todo),
                  child: const Text('Add',style: TextStyle(color: Colors.deepPurpleAccent,fontSize: 16),),
                ),
              ],
            ),

          ],
        );
      },
    );
  }
}
