// task_state.dart

import 'package:equatable/equatable.dart';
import '../../../data/models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final int totalTasks; // Add totalTasks here

  TaskLoaded({required this.tasks, required this.totalTasks}); // Update constructor

  @override
  List<Object> get props => [tasks, totalTasks];
}

class TaskError extends TaskState {
  final String message;

  TaskError({required this.message});

  @override
  List<Object> get props => [message];
}
