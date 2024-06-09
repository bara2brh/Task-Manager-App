import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

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
