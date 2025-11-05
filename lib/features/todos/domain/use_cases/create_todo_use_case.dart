import 'package:dartz/dartz.dart';
import '../../../../core/util/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

class CreateTodoUseCase {
  final TodosRepository _repository;

  CreateTodoUseCase(this._repository);

  Future<Result<Todo>> call(String title, String description, DateTime? dueDate) async {
    if (title.trim().isEmpty) {
      return const Left(
        Failure.unknown(message: 'Title cannot be empty'),
      );
    }

    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      isCompleted: false,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createTodo(todo);
  }
}
