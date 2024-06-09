import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/data/repositories/task_repository.dart';
import 'package:task_manager_app/services/sqlite.dart';
import 'package:task_manager_app/ui/screens/login_screen.dart';
import '../logic/blocs/auth/auth_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../ui/screens/task_list_screen.dart';
import 'logic/blocs/task/task_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Dio dio = Dio();
  final ApiService apiService = ApiService(dio);
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final TaskRepository taskRepository = TaskRepository(dio);
  final AuthRepository authRepository = AuthRepository(apiService, preferences);
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final String? token = await authRepository.getSession();
  runApp(MyApp(
    authRepository: authRepository,
    preferences: preferences,
    taskRepository: taskRepository,
    token: token,
    databaseHelper: databaseHelper,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TaskRepository taskRepository;
  final String? token;
  final SharedPreferences preferences;
  final DatabaseHelper databaseHelper;

  const MyApp({
    Key? key,
    required this.authRepository,
    required this.taskRepository,
    required this.preferences,
    required this.token,
    required this.databaseHelper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository, preferences),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(taskRepository, databaseHelper),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager App',
        home: token != null ? TaskListScreen(databaseHelper: databaseHelper,) : LoginScreen(),
        routes: {
          '/tasks': (context) => BlocProvider(
            create: (context) => TaskBloc(taskRepository, databaseHelper),
            child: TaskListScreen(databaseHelper: databaseHelper,),
          ),
        },
      ),
    );
  }
}
