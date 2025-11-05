import 'package:dartz/dartz.dart';
import '../../../../core/util/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../datasources/todos_local_datasource.dart';

class TodosRepositoryImpl implements TodosRepository {
  final TodosLocalDataSource _localDataSource;

  TodosRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Todo>>> getAllTodos() async {
    return await _localDataSource.getAllTodos();
  }

  @override
  Future<Result<Todo>> getTodoById(String id) async {
    final allTodosResult = await getAllTodos();
    return allTodosResult.fold(
      (failure) => Left(failure),
      (todos) {
        try {
          final todo = todos.firstWhere((t) => t.id == id);
          return Right(todo);
        } catch (e) {
          return Left(Failure.unknown(message: 'Todo not found', error: e));
        }
      },
    );
  }

  @override
  Future<Result<Todo>> createTodo(Todo todo) async {
    final saveResult = await _localDataSource.saveTodo(todo);
    return saveResult.fold(
      (failure) => Left(failure),
      (_) => Right(todo),
    );
  }

  @override
  Future<Result<Todo>> updateTodo(Todo todo) async {
    final saveResult = await _localDataSource.saveTodo(todo);
    return saveResult.fold(
      (failure) => Left(failure),
      (_) => Right(todo),
    );
  }

  @override
  Future<Result<void>> deleteTodo(String id) async {
    return await _localDataSource.deleteTodo(id);
  }

  @override
  Future<Result<List<Todo>>> getCompletedTodos() async {
    final allTodosResult = await getAllTodos();
    return allTodosResult.fold(
      (failure) => Left(failure),
      (todos) => Right(todos.where((t) => t.isCompleted).toList()),
    );
  }

  @override
  Future<Result<List<Todo>>> getPendingTodos() async {
    final allTodosResult = await getAllTodos();
    return allTodosResult.fold(
      (failure) => Left(failure),
      (todos) => Right(todos.where((t) => !t.isCompleted).toList()),
    );
  }
}
