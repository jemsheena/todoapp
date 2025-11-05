import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/util/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/todo.dart';
import '../dtos/todo_dto.dart';

abstract class TodosLocalDataSource {
  Future<Result<List<Todo>>> getAllTodos();
  Future<Result<void>> saveTodos(List<Todo> todos);
  Future<Result<void>> saveTodo(Todo todo);
  Future<Result<void>> deleteTodo(String id);
}

class TodosLocalDataSourceImpl implements TodosLocalDataSource {
  final SharedPreferences _prefs;
  static const _keyTodos = 'todos_list';

  TodosLocalDataSourceImpl(this._prefs);

  @override
  Future<Result<List<Todo>>> getAllTodos() async {
    try {
      final todosJson = _prefs.getString(_keyTodos);
      if (todosJson == null || todosJson.isEmpty) {
        return Right([]);
      }

      final List<dynamic> jsonList = json.decode(todosJson);
      // Filter out any null or invalid entries and handle parsing errors gracefully
      final todos = <Todo>[];
      for (final item in jsonList) {
        try {
          if (item is Map<String, dynamic>) {
            // Validate required fields before parsing
            if (item['id'] is String && item['title'] is String && item['description'] is String) {
              final dto = TodoDto.fromJson(item);
              todos.add(dto.toDomain());
            }
          }
        } catch (e) {
          // Skip invalid todo entries
          continue;
        }
      }

      return Right(todos);
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to load todos: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> saveTodos(List<Todo> todos) async {
    try {
      final todosJson = todos.map((todo) => todo.toDto().toJson()).toList();
      await _prefs.setString(_keyTodos, json.encode(todosJson));
      return const Right(null);
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to save todos: $e'),
      );
    }
  }

  @override
  Future<Result<void>> saveTodo(Todo todo) async {
    try {
      final allTodosResult = await getAllTodos();
      return allTodosResult.fold(
        (failure) => Left(failure),
        (todos) async {
          final index = todos.indexWhere((t) => t.id == todo.id);
          if (index >= 0) {
            todos[index] = todo;
          } else {
            todos.add(todo);
          }
          return await saveTodos(todos);
        },
      );
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to save todo: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteTodo(String id) async {
    try {
      final allTodosResult = await getAllTodos();
      return allTodosResult.fold(
        (failure) => Left(failure),
        (todos) async {
          todos.removeWhere((t) => t.id == id);
          return await saveTodos(todos);
        },
      );
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to delete todo: $e'),
      );
    }
  }
}
