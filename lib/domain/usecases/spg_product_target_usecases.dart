import '../../domain/entities/spg_product_target_entity.dart';
import '../../domain/repositories/spg_product_target_repository.dart';

class GetTargetsByEvent {
  final SpgProductTargetRepository repository;

  GetTargetsByEvent(this.repository);

  Future<List<SpgProductTargetEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class GetTargetsByEventSpg {
  final SpgProductTargetRepository repository;

  GetTargetsByEventSpg(this.repository);

  Future<List<SpgProductTargetEntity>> call(String eventId, String spgId) async {
    return await repository.getByEventSpg(eventId, spgId);
  }
}

class GetTargetByEventSpgProduct {
  final SpgProductTargetRepository repository;

  GetTargetByEventSpgProduct(this.repository);

  Future<SpgProductTargetEntity?> call(String eventId, String spgId, String productId) async {
    return await repository.getByEventSpgProduct(eventId, spgId, productId);
  }
}

class CreateSpgProductTarget {
  final SpgProductTargetRepository repository;

  CreateSpgProductTarget(this.repository);

  Future<SpgProductTargetEntity> call(SpgProductTargetEntity target) async {
    return await repository.create(target);
  }
}

class UpdateSpgProductTarget {
  final SpgProductTargetRepository repository;

  UpdateSpgProductTarget(this.repository);

  Future<SpgProductTargetEntity> call(SpgProductTargetEntity target) async {
    return await repository.update(target);
  }
}

class DeleteSpgProductTarget {
  final SpgProductTargetRepository repository;

  DeleteSpgProductTarget(this.repository);

  Future<void> call(String id) async {
    await repository.delete(id);
  }
}

class BulkCreateOrUpdateTargets {
  final SpgProductTargetRepository repository;

  BulkCreateOrUpdateTargets(this.repository);

  Future<void> call(List<SpgProductTargetEntity> targets) async {
    await repository.bulkCreateOrUpdate(targets);
  }
}