import '../../domain/entities/spg_entity.dart';
import '../../domain/repositories/spg_repository.dart';

class GetAllSpgs {
  final SpgRepository repository;

  GetAllSpgs(this.repository);

  Future<List<SpgEntity>> call() async {
    return await repository.getAll();
  }
}

class GetActiveSpgs {
  final SpgRepository repository;

  GetActiveSpgs(this.repository);

  Future<List<SpgEntity>> call() async {
    return await repository.getActive();
  }
}

class GetSpgById {
  final SpgRepository repository;

  GetSpgById(this.repository);

  Future<SpgEntity?> call(String id) async {
    return await repository.getById(id);
  }
}

class CreateSpg {
  final SpgRepository repository;

  CreateSpg(this.repository);

  Future<SpgEntity> call(String name) async {
    return await repository.create(
      SpgEntity(
        id: '',
        name: name,
      ),
    );
  }
}

class UpdateSpg {
  final SpgRepository repository;

  UpdateSpg(this.repository);

  Future<SpgEntity> call(SpgEntity spg) async {
    return await repository.update(spg);
  }
}

class SoftDeleteSpg {
  final SpgRepository repository;

  SoftDeleteSpg(this.repository);

  Future<void> call(String id) async {
    await repository.softDelete(id);
  }
}