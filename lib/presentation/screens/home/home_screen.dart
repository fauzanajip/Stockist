import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../../domain/entities/event_entity.dart';
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../blocs/event_bloc/event_state.dart';

import '../event/event_setup_screen.dart';
import '../../widgets/event_dashboard_view.dart';
import '../../../core/utils/excel_export_service.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/cash_bloc/cash_bloc.dart';
import '../../blocs/cash_bloc/cash_event.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/product_bloc/product_state.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_event.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadAllEvents());
  }

  Future<void> _onRefresh() async {
    context.read<EventBloc>().add(LoadAllEvents());
    final state = context.read<EventBloc>().state;
    if (state is EventsLoaded) {
      final activeEvent = state.events.cast<EventEntity?>().firstWhere(
        (e) => e?.isActive ?? false,
        orElse: () => null,
      );
      if (activeEvent != null) {
        _triggerEventDataLoad(activeEvent.id);
      }
    }
  }

  void _triggerEventDataLoad(String eventId) {
    context.read<StockBloc>().add(LoadStockByEvent(eventId: eventId));
    context.read<SalesBloc>().add(LoadAllSalesByEvent(eventId: eventId));
    context.read<CashBloc>().add(LoadAllCashByEvent(eventId: eventId));
    context.read<EventProductBloc>().add(
      LoadAvailableProducts(eventId: eventId),
    );
    context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: eventId));

    // Load data needed for export
    context.read<SpgBloc>().add(LoadAllSpqs());
    context.read<ProductBloc>().add(LoadAllProducts());
  }

  Future<void> _exportData(EventEntity event) async {
    final stockState = context.read<StockBloc>().state;
    final salesState = context.read<SalesBloc>().state;
    final cashState = context.read<CashBloc>().state;
    final spgState = context.read<SpgBloc>().state;
    final productState = context.read<ProductBloc>().state;
    final eventSpgState = context.read<EventSpgBloc>().state;
    final eventProductState = context.read<EventProductBloc>().state;

    if (spgState is! SpqsLoaded ||
        productState is! ProductsLoaded ||
        eventSpgState is! AvailableSpgsLoaded ||
        eventProductState is! AvailableProductsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tunggu sebentar, sedang menyiapkan data...'),
        ),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyiapkan Laporan Excel...')),
      );

      final filePath = await ExcelExportService.exportEvent(
        event: event,
        eventSpgs: eventSpgState.assignedSpgs,
        spgs: spgState.spqs,
        eventProducts: eventProductState.assignedProducts,
        products: productState.products,
        stockMutations: stockState.mutations,
        sales: salesState.allSales,
        cashRecords: cashState.allCash,
      );

      await ExcelExportService.shareExcel(filePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengekspor: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventsLoaded) {
          final activeEvent = state.events.cast<EventEntity?>().firstWhere(
            (e) => e?.isActive ?? false,
            orElse: () => null,
          );
          if (activeEvent != null) {
            _triggerEventDataLoad(activeEvent.id);
          }
        }
      },
      builder: (context, state) {
        final activeEvent = (state is EventsLoaded)
            ? state.events.cast<EventEntity?>().firstWhere(
                (e) => e?.isActive ?? false,
                orElse: () => null,
              )
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(activeEvent != null ? 'Dashboard' : 'Stockist App'),
            actions: [
              if (activeEvent != null)
                IconButton(
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: 'Export Laporan Excel',
                  onPressed: () => _exportData(activeEvent),
                ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.pushNamed('settings'),
              ),
            ],
          ),
          body: _buildBody(context, state, activeEvent),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    EventState state,
    EventEntity? activeEvent,
  ) {
    if (state is EventLoading || state is EventInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EventsLoaded) {
      if (activeEvent != null) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: EventDashboardView(event: activeEvent),
        );
      }

      return _buildEmptyState(context);
    }

    if (state is EventError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<EventBloc>().add(LoadAllEvents()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dashboard_customize_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Dashboard Belum Aktif',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih event yang ingin Anda fokuskan atau buat event baru untuk ditampilkan di Dashboard ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.pushNamed('event_focus'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('PILIH EVENT AKTIF'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.pushNamed('create_event'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('BUAT EVENT BARU'),
            ),
          ],
        ),
      ),
    );
  }
}
