import '../entities/spg_entity.dart';

abstract class SpgRepository {
  Future<List<SpgEntity>> getAll();
  Future<List<SpgEntity>> getActive();
  Future<SpgEntity?> getById(String id);
  Future<SpgEntity> create(SpgEntity spg);
  Future<SpgEntity> update(SpgEntity spg);
  Future<void> delete(String id);
  Future<void> softDelete(String id);
}
