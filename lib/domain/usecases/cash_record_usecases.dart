import 'package:uuid/uuid.dart';
import '../../domain/entities/cash_record_entity.dart';
import '../../domain/repositories/cash_record_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

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

  Future<Either<Failure, CashRecordEntity>> call(CreateOrUpdateCashRecordParams params) async {
    final existingResult = await repository.getByEventAndSpg(
      params.eventId,
      params.spgId,
    );

    return existingResult.fold(
      (failure) => Left(failure),
      (existing) {
        if (existing == null) {
          return repository.create(
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
          return repository.update(
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
      },
    );
  }
}

class GetCashRecordByEventSpg {
  final CashRecordRepository repository;

  GetCashRecordByEventSpg(this.repository);

  Future<Either<Failure, CashRecordEntity?>> call(String eventId, String spgId) async {
    return await repository.getByEventAndSpg(eventId, spgId);
  }
}
