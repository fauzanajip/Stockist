import 'package:get_it/get_it.dart';
import '../data/data_sources/database_helper.dart';
import '../data/repositories/event_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/spg_repository_impl.dart';
import '../data/repositories/spb_repository_impl.dart';
import '../data/repositories/event_spg_repository_impl.dart';
import '../data/repositories/event_product_repository_impl.dart';
import '../data/repositories/stock_mutation_repository_impl.dart';
import '../data/repositories/sales_repository_impl.dart';
import '../data/repositories/cash_record_repository_impl.dart';
import '../data/repositories/backup_log_repository_impl.dart';
import '../domain/repositories/event_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/spg_repository.dart';
import '../domain/repositories/spb_repository.dart';
import '../domain/repositories/event_spg_repository.dart';
import '../domain/repositories/event_product_repository.dart';
import '../domain/repositories/stock_mutation_repository.dart';
import '../domain/repositories/sales_repository.dart';
import '../domain/repositories/cash_record_repository.dart';
import '../domain/repositories/backup_log_repository.dart';
import '../domain/usecases/event_usecases.dart';
import '../domain/usecases/event_product_usecases.dart';
import '../domain/usecases/event_spg_usecases.dart';
import '../domain/usecases/stock_mutation_usecases.dart';
import '../domain/usecases/sales_usecases.dart';
import '../domain/usecases/cash_record_usecases.dart';
import '../presentation/blocs/event_bloc/event_bloc.dart';
import '../presentation/blocs/spg_bloc/spg_bloc.dart';
import '../presentation/blocs/product_bloc/product_bloc.dart';
import '../presentation/blocs/stock_bloc/stock_bloc.dart';
import '../presentation/blocs/sales_bloc/sales_bloc.dart';
import '../presentation/blocs/cash_bloc/cash_bloc.dart';
// TODO: Add event_product_bloc and event_spg_bloc when needed

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // Repositories
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<SpgRepository>(
    () => SpgRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<SpbRepository>(
    () => SpbRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<EventSpgRepository>(
    () => EventSpgRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<EventProductRepository>(
    () => EventProductRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<StockMutationRepository>(
    () => StockMutationRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<CashRecordRepository>(
    () => CashRecordRepositoryImpl(dbHelper: sl()),
  );
  sl.registerLazySingleton<BackupLogRepository>(
    () => BackupLogRepositoryImpl(dbHelper: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateEvent(sl()));
  sl.registerLazySingleton(() => GetAllEvents(sl()));
  sl.registerLazySingleton(() => GetEventById(sl()));
  sl.registerLazySingleton(() => CloseEvent(sl()));
  sl.registerLazySingleton(() => ReopenEvent(sl()));
  
  sl.registerLazySingleton(() => AssignProductToEvent(sl()));
  sl.registerLazySingleton(() => RemoveProductFromEvent(sl()));
  sl.registerLazySingleton(() => GetProductsByEvent(sl()));
  
  sl.registerLazySingleton(() => AssignSpgToEvent(sl()));
  sl.registerLazySingleton(() => RemoveSpgFromEvent(sl()));
  sl.registerLazySingleton(() => GetSpgsByEvent(sl()));
  
  sl.registerLazySingleton(() => CreateStockMutation(sl()));
  sl.registerLazySingleton(() => GetStockMutationsByEvent(sl()));
  sl.registerLazySingleton(() => GetStockMutationsByEventSpg(sl()));
  sl.registerLazySingleton(() => GetTotalGiven(sl()));
  sl.registerLazySingleton(() => GetTotalReturn(sl()));
  
  sl.registerLazySingleton(() => CreateOrUpdateSales(sl()));
  sl.registerLazySingleton(() => GetSalesByEventSpg(sl()));
  
  sl.registerLazySingleton(() => CreateOrUpdateCashRecord(sl()));
  sl.registerLazySingleton(() => GetCashRecordByEventSpg(sl()));

  // Blocs
  sl.registerFactory(
    () => EventBloc(
      getAllEvents: sl(),
      getEventById: sl(),
      createEvent: sl(),
      closeEvent: sl(),
      reopenEvent: sl(),
    ),
  );
  sl.registerFactory(
    () => SpgBloc(),
  );
  sl.registerFactory(
    () => ProductBloc(),
  );
  sl.registerFactory(
    () => StockBloc(
      createStockMutation: sl(),
      getTotalGiven: sl(),
      getTotalReturn: sl(),
    ),
  );
  sl.registerFactory(
    () => SalesBloc(
      createOrUpdateSales: sl(),
      getSalesByEventSpg: sl(),
    ),
  );
  sl.registerFactory(
    () => CashBloc(
      createOrUpdateCashRecord: sl(),
      getCashRecordByEventSpg: sl(),
    ),
  );
}
