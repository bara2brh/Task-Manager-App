import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../services/local_service.dart';
import '../../../services/sqlite.dart'; // Import your SQLite database helper

// Events
abstract class TaskEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final int limit;
  final int skip;

  LoadTasks({this.limit = 10, this.skip = 0});

  @override
  List<Object> get props => [limit, skip];
}

class AddTask extends TaskEvent {
  final String todo;
  final int userId;

  AddTask({required this.todo, required this.userId});

  @override
  List<Object> get props => [todo, userId];
}

class DeleteTask extends TaskEvent {
  final int id;

  DeleteTask({required this.id});

  @override
  List<Object> get props => [id];
}

class UpdateTask extends TaskEvent {
  final int id;
  final String todo;
  final bool completed;

  UpdateTask({required this.id, required this.todo, required this.completed});

  @override
  List<Object> get props => [id, todo, completed];
}

class FetchTotalTasks extends TaskEvent {}

// States
abstract class TaskState extends Equatable {
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final bool hasReachedMax;
  final int totalTasks;

  TaskLoaded({required this.tasks, this.hasReachedMax = false, required this.totalTasks});

  TaskLoaded copyWith({List<Task>? tasks, bool? hasReachedMax, int? totalTasks}) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalTasks: totalTasks ?? this.totalTasks,
    );
  }

  @override
  List<Object> get props => [tasks, hasReachedMax, totalTasks];
}

class TaskError extends TaskState {
  final String message;

  TaskError({required this.message});

  @override
  List<Object> get props => [message];
}

class TotalTasksLoaded extends TaskState {
  final int totalTasks;

  TotalTasksLoaded({required this.totalTasks});

  @override
  List<Object> get props => [totalTasks];
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final DatabaseHelper _databaseHelper; // Use SQLite database helper instead of LocalStorageService

  TaskBloc(this._taskRepository, this._databaseHelper) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
    on<UpdateTask>(_onUpdateTask);
    on<FetchTotalTasks>(_onFetchTotalTasks);

    // Ensure tasks are fetched initially
    add(LoadTasks());
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    print("Loading tasks...");
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userId = preferences.getInt('userId');

    try {
      emit(TaskLoading());

      final tasks = await _databaseHelper.getTasks(userId!);
      final totalTasks = tasks.length;

      final paginatedTasks = tasks.skip(event.skip).take(event.limit).toList();

      emit(TaskLoaded(tasks: paginatedTasks, hasReachedMax: paginatedTasks.length < event.limit, totalTasks: totalTasks));

      if (tasks.isEmpty) {
        final tasksResult = await _taskRepository.fetchTasks(limit: event.limit, skip: event.skip, userId: userId);
        final fetchedTasks = tasksResult.tasks;
        final fetchedTotalTasks = tasksResult.totalTasks;

        for (var task in fetchedTasks) {
          await _databaseHelper.insertTask(task, userId);
        }

        emit(TaskLoaded(tasks: fetchedTasks, hasReachedMax: fetchedTasks.length >= fetchedTotalTasks, totalTasks: fetchedTotalTasks));
      }
    } catch (e) {
      emit(TaskError(message: 'Failed to load tasks: ${e.toString()}'));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final currentState = state;
      if (currentState is TaskLoaded) {
        // Create a new task object
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch, // Generate a temporary unique ID
          todo: event.todo,
          completed: false,
        );

        // Insert the new task into the local SQLite database
        await _databaseHelper.insertTask(newTask, event.userId);

        // Create an updated list of tasks with the new task added
        final updatedTasks = List<Task>.from(currentState.tasks)..add(newTask);

        // Emit the new state with the updated task list and incremented total tasks
        emit(currentState.copyWith(tasks: updatedTasks, totalTasks: currentState.totalTasks + 1));
      } else if (currentState is TaskInitial || currentState is TaskLoading) {
        // If the current state is TaskInitial or TaskLoading, fetch the tasks first
        final userId = event.userId;
        final tasks = await _databaseHelper.getTasks(userId);
        final totalTasks = tasks.length;

        // After fetching tasks, add the new task
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch, // Generate a temporary unique ID
          todo: event.todo,
          completed: false,
        );

        await _databaseHelper.insertTask(newTask, userId);

        final updatedTasks = List<Task>.from(tasks)..add(newTask);

        emit(TaskLoaded(tasks: updatedTasks, totalTasks: totalTasks + 1));
      }
    } catch (e) {
      emit(TaskError(message: 'Failed to add task: ${e.toString()}'));
    }
  }




  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final currentState = state;
      if (currentState is TaskLoaded) {
        final updatedTask = Task(
          id: event.id,
          todo: event.todo,
          completed: event.completed,
        );

        await _databaseHelper.updateTask(updatedTask);

        final updatedTasks = currentState.tasks.map((task) {
          return task.id == event.id ? updatedTask : task;
        }).toList();

        print("Task updated: ${updatedTask.id}, ${updatedTask.todo}, ${updatedTask.completed}");

        emit(currentState.copyWith(tasks: updatedTasks));
      }
    } catch (e) {
      print("Failed to update task: ${e.toString()}");
      emit(TaskError(message: 'Failed to update task: ${e.toString()}'));
    }
  }




  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.tasks.where((task) => task.id != event.id).toList();
      await _databaseHelper.deleteTask(event.id);
      emit(currentState.copyWith(tasks: updatedTasks, totalTasks: currentState.totalTasks - 1));
    }
  }
  void _onFetchTotalTasks(FetchTotalTasks event, Emitter<TaskState> emit) async {
    try {
      final totalTasks = await _taskRepository.fetchTotalTasks();
      emit(TotalTasksLoaded(totalTasks: totalTasks));
    } catch (e) {
      emit(TaskError(message: 'Failed to fetch total tasks: ${e.toString()}'));
    }
  }
}