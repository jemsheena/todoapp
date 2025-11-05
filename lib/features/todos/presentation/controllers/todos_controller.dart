import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import '../../domain/use_cases/get_all_todos_use_case.dart';
import '../../domain/use_cases/create_todo_use_case.dart';
import '../../domain/use_cases/toggle_todo_use_case.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../data/repositories/todos_repository_impl.dart';
import '../../data/datasources/todos_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final todosLocalDataSourceProvider = Provider<TodosLocalDataSource>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => TodosLocalDataSourceImpl(prefs),
    loading: () => throw UnimplementedError('SharedPreferences not initialized'),
    error: (err, stack) {
      // err might be null, so handle it safely
      final errorMessage = err != null ? err.toString() : 'Unknown error';
      throw StateError('Failed to initialize SharedPreferences: $errorMessage');
    },
  );
});

final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  final localDataSource = ref.watch(todosLocalDataSourceProvider);
  return TodosRepositoryImpl(localDataSource);
});

final getAllTodosUseCaseProvider = Provider<GetAllTodosUseCase>((ref) {
  final repository = ref.watch(todosRepositoryProvider);
  return GetAllTodosUseCase(repository);
});

final createTodoUseCaseProvider = Provider<CreateTodoUseCase>((ref) {
  final repository = ref.watch(todosRepositoryProvider);
  return CreateTodoUseCase(repository);
});

final toggleTodoUseCaseProvider = Provider<ToggleTodoUseCase>((ref) {
  final repository = ref.watch(todosRepositoryProvider);
  return ToggleTodoUseCase(repository);
});

final todosStateProvider = StateNotifierProvider<TodosController, TodosState>(
  (ref) {
    // The provider will automatically wait for all dependencies to be ready
    // If SharedPreferences is not ready, todosLocalDataSourceProvider will throw
    // and this provider will be in error state until SharedPreferences is ready
    final getAllTodos = ref.watch(getAllTodosUseCaseProvider);
    final createTodo = ref.watch(createTodoUseCaseProvider);
    final toggleTodo = ref.watch(toggleTodoUseCaseProvider);
    return TodosController(getAllTodos, createTodo, toggleTodo)..loadTodos();
  },
);

class TodosState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  TodosState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
  });

  List<Todo> get completedTodos => todos.where((t) => t.isCompleted).toList();
  List<Todo> get pendingTodos => todos.where((t) => !t.isCompleted).toList();

  TodosState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TodosController extends StateNotifier<TodosState> {
  final GetAllTodosUseCase _getAllTodos;
  final CreateTodoUseCase _createTodo;
  final ToggleTodoUseCase _toggleTodo;

  TodosController(
    this._getAllTodos,
    this._createTodo,
    this._toggleTodo,
  ) : super(TodosState());

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getAllTodos();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (todos) {
        state = state.copyWith(
          todos: todos,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> addTodo(String title, String description, DateTime? dueDate) async {
    final result = await _createTodo(title, description, dueDate);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (todo) {
        final updatedTodos = [...state.todos, todo];
        state = state.copyWith(todos: updatedTodos, error: null);
      },
    );
  }

  Future<void> toggleTodo(Todo todo) async {
    final result = await _toggleTodo(todo);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (updatedTodo) {
        final updatedTodos = state.todos.map((t) => t.id == todo.id ? updatedTodo : t).toList();
        state = state.copyWith(todos: updatedTodos, error: null);
      },
    );
  }

  Future<void> deleteTodo(String id) async {
    // TODO: Implement delete use case
    final updatedTodos = state.todos.where((t) => t.id != id).toList();
    state = state.copyWith(todos: updatedTodos);
  }
}
