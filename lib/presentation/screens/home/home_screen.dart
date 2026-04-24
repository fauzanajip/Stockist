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
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainerLowest,
            centerTitle: false,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOCKIST BASE COMMAND',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  activeEvent != null ? 'MISSION TELEMETRY' : 'READY FOR DEPLOYMENT',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              if (activeEvent != null)
                IconButton(
                  icon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
                  tooltip: 'Export Laporan Excel',
                  onPressed: () => _exportData(activeEvent),
                ),
              IconButton(
                icon: const Icon(Icons.settings_input_component_outlined),
                onPressed: () => context.pushNamed('settings'),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.surfaceContainerHigh, height: 1),
            ),
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
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state is EventsLoaded) {
      if (activeEvent != null) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          displacement: 20,
          color: AppColors.primary,
          child: EventDashboardView(event: activeEvent),
        );
      }

      return _buildEmptyState(context);
    }

    if (state is EventError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_bad_outlined, size: 48, color: AppColors.error),
              const SizedBox(height: 24),
              Text(
                'SYSTEM DATA ERROR'.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => context.read<EventBloc>().add(LoadAllEvents()),
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('RETRY SYNC'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: const Icon(
                  Icons.radar_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'NO ACTIVE MISSIONS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SYSTEM IS ONLINE BUT NO MISSION CRITERIA HAS BEEN SELECTED FOR TELEMETRY MONITORING.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              _buildTacticalButton(
                context,
                label: 'DEPLOY ACTIVE EVENT',
                icon: Icons.rocket_launch_outlined,
                onPressed: () => context.pushNamed('event_focus'),
                primary: true,
              ),
              const SizedBox(height: 12),
              _buildTacticalButton(
                context,
                label: 'INITIALIZE NEW MISSION',
                icon: Icons.add_moderator_outlined,
                onPressed: () => context.pushNamed('create_event'),
                primary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTacticalButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.surfaceContainerLowest,
          border: Border.all(
            color: primary ? AppColors.primary : AppColors.surfaceContainerHigh,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: primary ? Colors.white : AppColors.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: primary ? Colors.white : AppColors.onSurface,
                letterSpacing: 1,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
