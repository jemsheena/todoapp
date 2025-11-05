import '../../../../core/util/result.dart';
import '../entities/todo.dart';

abstract class TodosRepository {
  Future<Result<List<Todo>>> getAllTodos();
  Future<Result<Todo>> getTodoById(String id);
  Future<Result<Todo>> createTodo(Todo todo);
  Future<Result<Todo>> updateTodo(Todo todo);
  Future<Result<void>> deleteTodo(String id);
  Future<Result<List<Todo>>> getCompletedTodos();
  Future<Result<List<Todo>>> getPendingTodos();
}


