import '../entities/spb_entity.dart';

abstract class SpbRepository {
  Future<List<SpbEntity>> getAll();
  Future<SpbEntity?> getById(String id);
  Future<SpbEntity> create(SpbEntity spb);
  Future<void> delete(String id);
}
