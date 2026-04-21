import '../../domain/entities/spb_entity.dart';
import '../../domain/repositories/spb_repository.dart';

class GetAllSpbs {
  final SpbRepository repository;

  GetAllSpbs(this.repository);

  Future<List<SpbEntity>> call() async {
    return await repository.getAll();
  }
}

class GetSpbById {
  final SpbRepository repository;

  GetSpbById(this.repository);

  Future<SpbEntity?> call(String id) async {
    return await repository.getById(id);
  }
}

class CreateSpb {
  final SpbRepository repository;

  CreateSpb(this.repository);

  Future<SpbEntity> call(String name) async {
    return await repository.create(
      SpbEntity(
        id: '',
        name: name,
      ),
    );
  }
}

class DeleteSpb {
  final SpbRepository repository;

  DeleteSpb(this.repository);

  Future<void> call(String id) async {
    await repository.delete(id);
  }
}