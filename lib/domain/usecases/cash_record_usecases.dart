import '../../domain/entities/cash_record_entity.dart';
import '../../domain/repositories/cash_record_repository.dart';

class CreateOrUpdateCashRecordParams {
  final String eventId;
  final String spgId;
  final double cashReceived;
  final double qrisReceived;
  final String? note;

  CreateOrUpdateCashRecordParams({
    required this.eventId,
    required this.spgId,
    required this.cashReceived,
    required this.qrisReceived,
    this.note,
  });
}

class CreateOrUpdateCashRecord {
  final CashRecordRepository repository;

  CreateOrUpdateCashRecord(this.repository);

  Future<CashRecordEntity> call(CreateOrUpdateCashRecordParams params) async {
    final existing = await repository.getByEventAndSpg(
      params.eventId,
      params.spgId,
    );

    if (existing == null) {
      return await repository.create(
        CashRecordEntity(
          id: '',
          eventId: params.eventId,
          spgId: params.spgId,
          cashReceived: params.cashReceived,
          qrisReceived: params.qrisReceived,
          note: params.note,
        ),
      );
    } else {
      return await repository.update(
        CashRecordEntity(
          id: existing.id,
          eventId: params.eventId,
          spgId: params.spgId,
          cashReceived: params.cashReceived,
          qrisReceived: params.qrisReceived,
          note: params.note,
        ),
      );
    }
  }
}

class GetCashRecordByEventSpg {
  final CashRecordRepository repository;

  GetCashRecordByEventSpg(this.repository);

  Future<CashRecordEntity?> call(String eventId, String spgId) async {
    return await repository.getByEventAndSpg(eventId, spgId);
  }
}

class GetCashRecordsByEvent {
  final CashRecordRepository repository;

  GetCashRecordsByEvent(this.repository);

  Future<List<CashRecordEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class BulkUpsertCashItem {
  final String spgId;
  final double cashReceived;
  final double qrisReceived;

  const BulkUpsertCashItem({
    required this.spgId,
    required this.cashReceived,
    required this.qrisReceived,
  });
}

class BulkUpsertCashParams {
  final String eventId;
  final List<BulkUpsertCashItem> cashItems;

  BulkUpsertCashParams({
    required this.eventId,
    required this.cashItems,
  });
}

class BulkUpsertCash {
  final CashRecordRepository repository;

  BulkUpsertCash(this.repository);

  Future<void> call(BulkUpsertCashParams params) async {
    for (final item in params.cashItems) {
      final existing = await repository.getByEventAndSpg(
        params.eventId,
        item.spgId,
      );

      if (existing != null) {
        await repository.update(
          CashRecordEntity(
            id: existing.id,
            eventId: params.eventId,
            spgId: item.spgId,
            cashReceived: item.cashReceived,
            qrisReceived: item.qrisReceived,
            note: existing.note,
          ),
        );
      } else {
        await repository.create(
          CashRecordEntity(
            id: '',
            eventId: params.eventId,
            spgId: item.spgId,
            cashReceived: item.cashReceived,
            qrisReceived: item.qrisReceived,
            note: null,
          ),
        );
      }
    }
  }
}
