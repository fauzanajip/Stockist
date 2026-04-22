import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/event/create_event_screen.dart';
import '../../presentation/screens/event/event_setup_screen.dart';
import '../../presentation/screens/spg/spg_list_screen.dart';
import '../../presentation/screens/spg/spg_detail_screen.dart';
import '../../presentation/screens/spg/spg_closing_screen.dart';
import '../../presentation/screens/stock/initial_distribution_screen.dart';
import '../../presentation/screens/stock/topup_screen.dart';
import '../../presentation/screens/stock/return_screen.dart';
import '../../presentation/screens/stock/stock_history_screen.dart';
import '../../presentation/screens/sales/sales_input_screen.dart';
import '../../presentation/screens/cash/cash_input_screen.dart';
import '../../presentation/screens/settings/backup_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/event_focus_screen.dart';
import '../../presentation/screens/settings/product_master_screen.dart';
import '../../presentation/screens/settings/spg_master_screen.dart';
import '../../presentation/screens/settings/spb_master_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // Home
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Event Routes
      GoRoute(
        path: '/event/create',
        name: 'create_event',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/event/:eventId/setup',
        name: 'event_setup',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventSetupScreen(eventId: eventId);
        },
      ),
      // SPG Routes
      GoRoute(
        path: '/event/:eventId/spg',
        name: 'spg_list',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return SpgListScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/event/:eventId/spg/:spgId',
        name: 'spg_detail',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return SpgDetailScreen(eventId: eventId, spgId: spgId);
        },
      ),
      GoRoute(
        path: '/event/:eventId/spg/:spgId/closing',
        name: 'spg_closing',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return SpgClosingScreen(eventId: eventId, spgId: spgId);
        },
      ),

      // Stock Routes
      GoRoute(
        path: '/event/:eventId/spg/:spgId/initial',
        name: 'initial_distribution',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return InitialDistributionScreen(eventId: eventId, spgId: spgId);
        },
      ),
      GoRoute(
        path: '/event/:eventId/spg/:spgId/topup',
        name: 'topup',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return TopupScreen(eventId: eventId, spgId: spgId);
        },
      ),
      GoRoute(
        path: '/event/:eventId/spg/:spgId/return',
        name: 'return',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return ReturnScreen(eventId: eventId, spgId: spgId);
        },
      ),
      GoRoute(
        path: '/event/:eventId/spg/:spgId/history',
        name: 'stock_history_spg',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return StockHistoryScreen(eventId: eventId, spgId: spgId);
        },
      ),
      GoRoute(
        path: '/event/:eventId/history',
        name: 'stock_history',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return StockHistoryScreen(eventId: eventId);
        },
      ),

      // Sales Routes
      GoRoute(
        path: '/event/:eventId/spg/:spgId/sales',
        name: 'sales_input',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return SalesInputScreen(eventId: eventId, spgId: spgId);
        },
      ),

      // Cash Routes
      GoRoute(
        path: '/event/:eventId/spg/:spgId/cash',
        name: 'cash_input',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final spgId = state.pathParameters['spgId']!;
          return CashInputScreen(eventId: eventId, spgId: spgId);
        },
      ),

      // Settings Routes
      GoRoute(
        path: '/settings/backup',
        name: 'backup',
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'focus',
            name: 'event_focus',
            builder: (context, state) => const EventFocusScreen(),
          ),
          GoRoute(
            path: 'products',
            name: 'product_master',
            builder: (context, state) => const ProductMasterScreen(),
          ),
          GoRoute(
            path: 'spg',
            name: 'spg_master',
            builder: (context, state) => const SpgMasterScreen(),
          ),
          GoRoute(
            path: 'spb',
            name: 'spb_master',
            builder: (context, state) => const SpbMasterScreen(),
          ),
        ],
      ),
    ],
  );
}
