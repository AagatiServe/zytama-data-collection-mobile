import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../local/app_database.dart';
import '../sync/sync_service.dart';
// import '../notifications/fcm_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/product/data/datasources/dashboard_remote_datasource.dart';
import '../../features/product/data/datasources/notification_remote_datasource.dart';
import '../../features/product/data/repositories/dashboard_repository_impl.dart';
import '../../features/product/data/repositories/notification_repository_impl.dart';
import '../../features/product/domain/repositories/dashboard_repository.dart';
import '../../features/product/domain/repositories/notification_repository.dart';
import '../../features/product/domain/usecases/check_barcode_usecase.dart';
import '../../features/product/domain/usecases/get_dashboard_usecase.dart';
import '../../features/product/domain/usecases/get_notifications_usecase.dart';
import '../../features/product/domain/usecases/upload_product_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/product/presentation/bloc/dashboard_bloc.dart';
import '../../features/product/presentation/bloc/notification_bloc.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Connectivity
  final connectivity = ConnectivityService();
  sl.registerLazySingleton<ConnectivityService>(() => connectivity);
  await connectivity.init();

  // Local database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckBarcodeUseCase(sl()));
  sl.registerLazySingleton(() => UploadProductUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));

  // Sync service
  sl.registerLazySingleton<SyncService>(
    () => SyncService(sl(), sl(), sl()),
  );

  // FCM service
  // sl.registerLazySingleton<FcmService>(() => FcmService(sl()));

  // BLoCs (factory so each widget tree gets a fresh instance)
  sl.registerFactory(() => AuthBloc(sl(), sl(), sl()));
  sl.registerFactory(() => ProductBloc(sl(), sl()));
  sl.registerFactory(() => DashboardBloc(sl()));
  sl.registerFactory(() => NotificationBloc(sl()));
}
