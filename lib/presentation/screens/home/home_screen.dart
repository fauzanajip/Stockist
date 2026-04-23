import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/constants/app_theme.dart';
import '../../../domain/entities/event_entity.dart';
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../blocs/event_bloc/event_state.dart';
import '../../widgets/event_dashboard_view.dart';
import '../../widgets/export_loading_dialog.dart';
import '../../widgets/export_success_dialog.dart';
import '../../widgets/permission_denied_dialog.dart';
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ExportLoadingDialog(),
    );

    try {
      final fileName =
          '${event.name}_${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.xlsx';

      final filePath = await ExcelExportService.exportEvent(
        event: event,
        eventSpgs: eventSpgState.assignedSpgs,
        spgs: spgState.spqs,
        spbs: eventSpgState.spbs,
        eventProducts: eventProductState.assignedProducts,
        products: productState.products,
        stockMutations: stockState.mutations,
        sales: salesState.allSales,
        cashRecords: cashState.allCash,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (Platform.isAndroid) {
        final savedPath = await ExcelExportService.saveToDownloads(
          filePath,
          fileName,
        );

        if (!mounted) return;

        if (savedPath != null) {
          _showSuccessDialog(savedPath, true);
        } else {
          _showPermissionDialog(filePath);
        }
      } else {
        final savedPath = await ExcelExportService.saveToDownloads(
          filePath,
          fileName,
        );

        if (!mounted) return;

        if (savedPath != null) {
          _showSuccessDialog(savedPath, true);
        } else {
          _showSuccessDialog(filePath, false);
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengekspor: $e')));
    }
  }

  void _showSuccessDialog(String filePath, bool saveSuccess) {
    showDialog(
      context: context,
      builder: (_) => ExportSuccessDialog(
        filePath: filePath,
        onSaveSuccess: saveSuccess,
        onOpenFile: () async {
          Navigator.of(context).pop();
          final success = await ExcelExportService.openFile(filePath);
          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No Excel viewer installed. Try Share instead.'),
              ),
            );
          }
        },
        onShare: () async {
          Navigator.of(context).pop();
          await ExcelExportService.shareExcel(filePath);
        },
      ),
    );
  }

  void _showPermissionDialog(String filePath) {
    showDialog(
      context: context,
      builder: (_) => PermissionDeniedDialog(
        onRequestPermission: () async {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const ExportLoadingDialog(),
          );

          final fileName =
              '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}.xlsx';

          final savedPath = await ExcelExportService.saveToDownloads(
            filePath,
            fileName,
          );

          if (!mounted) return;
          Navigator.of(context).pop();

          if (savedPath != null) {
            _showSuccessDialog(savedPath, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission denied. Using Share instead.'),
              ),
            );
            await ExcelExportService.shareExcel(filePath);
          }
        },
        onShareOnly: () async {
          Navigator.of(context).pop();
          await ExcelExportService.shareExcel(filePath);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
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
