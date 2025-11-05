import '../../../../core/util/result.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

class ToggleTodoUseCase {
  final TodosRepository _repository;

  ToggleTodoUseCase(this._repository);

  Future<Result<Todo>> call(Todo todo) async {
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    return await _repository.updateTodo(updatedTodo);
  }
}


