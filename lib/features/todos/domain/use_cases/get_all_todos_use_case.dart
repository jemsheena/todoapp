import '../../../../core/util/result.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

class GetAllTodosUseCase {
  final TodosRepository _repository;

  GetAllTodosUseCase(this._repository);

  Future<Result<List<Todo>>> call() async {
    return await _repository.getAllTodos();
  }
}


