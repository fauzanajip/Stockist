import '../entities/cash_record_entity.dart';

abstract class CashRecordRepository {
  Future<List<CashRecordEntity>> getByEvent(String eventId);
  Future<CashRecordEntity?> getByEventAndSpg(String eventId, String spgId);
  Future<CashRecordEntity> create(CashRecordEntity cashRecord);
  Future<CashRecordEntity> update(CashRecordEntity cashRecord);
  Future<void> delete(String id);
}
