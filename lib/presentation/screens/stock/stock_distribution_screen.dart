import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../core/constants/app_theme.dart';
import '../../../domain/entities/pending_topup_entity.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/entities/spb_entity.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/event_spg_entity.dart';
import '../../blocs/pending_topup_bloc/pending_topup_bloc.dart';
import '../../blocs/pending_topup_bloc/pending_topup_event.dart';
import '../../blocs/pending_topup_bloc/pending_topup_state.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_state.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';
import '../../blocs/spb_bloc/spb_bloc.dart';
import '../../blocs/spb_bloc/spb_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../../core/utils/formatters.dart' as app_formatters;

class StockDistributionScreen extends StatefulWidget {
  final String eventId;

  const StockDistributionScreen({super.key, required this.eventId});

  @override
  State<StockDistributionScreen> createState() => _StockDistributionScreenState();
}

class _StockDistributionScreenState extends State<StockDistributionScreen> {
  String? _selectedSpbId;
  String? _selectedSpgId;
  String? _selectedProductId;
  int _qty = 0;
  String? _historyFilterSpbId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<PendingTopupBloc>().add(LoadPendingTopupsEvent(eventId: widget.eventId));
  }

  int _calculateSpgStock(StockState stockState, SalesState salesState, String spgId, String productId) {
    final mutations = stockState.mutations.where(
      (m) => m.spgId == spgId && m.productId == productId
    );

    final given = mutations.where(
      (m) => m.type == MutationType.initial || m.type == MutationType.topup
    ).fold(0, (sum, m) => sum + m.qty);

    final returned = mutations.where(
      (m) => m.type == MutationType.returnMutation
    ).fold(0, (sum, m) => sum + m.qty);

    final sold = salesState.allSales.where(
      (s) => s.spgId == spgId && s.productId == productId
    ).fold(0, (sum, s) => sum + s.qtySold);

    return given - returned - sold;
  }

  int _calculateWarehouseStock(StockState stockState, String productId) {
    final totalIn = stockState.mutations.where(
      (m) => m.productId == productId && m.type == MutationType.distributorToEvent
    ).fold(0, (sum, m) => sum + m.qty);

    final totalDistributed = stockState.mutations.where(
      (m) => m.productId == productId && m.spgId != 'WAREHOUSE' && 
      (m.type == MutationType.initial || m.type == MutationType.topup)
    ).fold(0, (sum, m) => sum + m.qty);

    final totalReturn = stockState.mutations.where(
      (m) => m.productId == productId && m.type == MutationType.returnMutation
    ).fold(0, (sum, m) => sum + m.qty);

    return totalIn - totalDistributed + totalReturn;
  }

  void _saveTopup() {
    if (_selectedSpgId == null || _selectedProductId == null || _qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SELECT_SPG_PRODUCT_AND_QTY')),
      );
      return;
    }

    final warehouseStock = _calculateWarehouseStock(
      context.read<StockBloc>().state,
      _selectedProductId!
    );

    if (_qty > warehouseStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('EXCEEDS_WAREHOUSE_STOCK: $warehouseStock')),
      );
      return;
    }

    context.read<PendingTopupBloc>().add(
      AddPendingTopupEvent(
        eventId: widget.eventId,
        spbId: _selectedSpbId,
        spgId: _selectedSpgId!,
        productId: _selectedProductId!,
        qty: _qty,
      ),
    );

    setState(() {
      _selectedSpgId = null;
      _selectedProductId = null;
      _qty = 0;
    });
  }

  void _toggleCheck(String id, bool isChecked) {
    context.read<PendingTopupBloc>().add(
      TogglePendingTopupCheckEvent(id: id, isChecked: isChecked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWebLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          Expanded(flex: 2, child: _buildHistorySection(context)),
          Container(width: 1, color: AppColors.surfaceContainerHigh),
          Expanded(flex: 3, child: _buildAddSection(context)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(context, showTabs: true),
        body: TabBarView(
          children: [
            _buildHistorySection(context),
            _buildAddSection(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {bool showTabs = false}) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STOCK_DISTRIBUTION_HUB',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Text(
            'STOCK DISTRIBUTION',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ],
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      bottom: showTabs
        ? const TabBar(
            tabs: [
              Tab(text: 'HISTORY'),
              Tab(text: 'ADD'),
            ],
            indicatorColor: AppColors.secondary,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          )
        : PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.surfaceContainerHigh, height: 1),
          ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return BlocBuilder<PendingTopupBloc, PendingTopupState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final filteredTopups = _historyFilterSpbId != null
          ? state.pendingTopups.where((t) => t.spbId == _historyFilterSpbId).toList()
          : state.pendingTopups;

        return Column(
          children: [
            _buildHistoryFilter(context),
            Expanded(
              child: filteredTopups.isEmpty
                ? _buildEmptyState(context)
                : _buildHistoryTable(context, filteredTopups),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryFilter(BuildContext context) {
    return BlocBuilder<EventSpgBloc, EventSpgState>(
      builder: (context, eventSpgState) {
        return BlocBuilder<SpbBloc, SpbState>(
          builder: (context, spbState) {
            final List<SpbEntity> allSpbs = spbState is SpbsLoaded ? spbState.spbs : [];
            final spgStateLoaded = eventSpgState is AvailableSpgsLoaded ? eventSpgState : null;
            final List<EventSpgEntity> assignedSpgs = spgStateLoaded?.assignedSpgs ?? [];
            
            final eventSpbIds = assignedSpgs
              .where((es) => es.spbId != null)
              .map((es) => es.spbId!)
              .toSet();
            
            final List<SpbEntity> eventSpbs = allSpbs.where((s) => eventSpbIds.contains(s.id)).toList();

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
              ),
              child: Row(
                children: [
                  Text(
                    'FILTER_SPB:',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownSearch<SpbEntity>(
                      selectedItem: _historyFilterSpbId != null 
                        ? eventSpbs.where((s) => s.id == _historyFilterSpbId).firstOrNull 
                        : null,
                      items: (f, cs) => eventSpbs.toList(),
                      itemAsString: (spb) => spb.name.toUpperCase(),
                      compareFn: (a, b) => a.id == b.id,
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'ALL_SPGS',
                          hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                            hintText: 'SEARCH_SPB',
                            hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        menuProps: MenuProps(
                          backgroundColor: AppColors.surface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        itemBuilder: (context, spb, isDisabled, isSelected) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Text(
                              spb.name.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          );
                        },
                      ),
                      onSelected: (spb) {
                        setState(() => _historyFilterSpbId = spb?.id);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'NO_DISTRIBUTION_RECORDS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context, List<PendingTopupEntity> topups) {
    final spbState = context.read<SpbBloc>().state;
    final spgState = context.read<EventSpgBloc>().state;
    final productState = context.read<EventProductBloc>().state;

    final List<SpbEntity> spbs = spbState is SpbsLoaded ? spbState.spbs : [];
    final spgStateLoaded = spgState is AvailableSpgsLoaded ? spgState : null;
    final List<SpgEntity> allSpgs = spgStateLoaded?.spgs ?? [];
    final List<ProductEntity> products = productState is AvailableProductsLoaded ? productState.products : [];

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 12,
        columns: const [
          DataColumn(label: Text('CHK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('SPB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('SPG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('PRODUCT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('QTY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          DataColumn(label: Text('AT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
        ],
        rows: topups.map((topup) {
          final spbName = topup.spbId != null
            ? spbs.where((s) => s.id == topup.spbId).firstOrNull?.name ?? '-'
            : '-';
          final spgName = allSpgs.where((s) => s.id == topup.spgId).firstOrNull?.name ?? topup.spgId;
          final productName = products.where((p) => p.id == topup.productId).firstOrNull?.name ?? topup.productId;

          return DataRow(
            cells: [
              DataCell(
                Checkbox(
                  value: topup.isChecked,
                  onChanged: topup.type == PendingTopupType.initial
                    ? null
                    : (val) => _toggleCheck(topup.id, val ?? false),
                ),
              ),
              DataCell(
                Text(
                  topup.type == PendingTopupType.initial ? 'INITIAL' : 'TOPUP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: topup.type == PendingTopupType.initial
                      ? AppColors.primary
                      : AppColors.secondary,
                  ),
                ),
              ),
              DataCell(Text(spbName.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
              DataCell(Text(spgName.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
              DataCell(Text(productName.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))),
              DataCell(Text('${topup.qty}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
              DataCell(
                Text(
                  app_formatters.Formatters.formatTime(topup.createdAt),
                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddSection(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAddForm(context, stockState, salesState),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: AppColors.surfaceContainerHigh),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddForm(BuildContext context, StockState stockState, SalesState salesState) {
    final spbState = context.read<SpbBloc>().state;
    final spgState = context.read<EventSpgBloc>().state;
    final productState = context.read<EventProductBloc>().state;

    final List<SpbEntity> allSpbs = spbState is SpbsLoaded ? spbState.spbs : [];
    final spgStateLoaded = spgState is AvailableSpgsLoaded ? spgState : null;
    final List<EventSpgEntity> assignedSpgs = spgStateLoaded?.assignedSpgs ?? [];
    final List<SpgEntity> allSpgs = spgStateLoaded?.spgs ?? [];
    final List<ProductEntity> products = productState is AvailableProductsLoaded ? productState.products : [];

    final eventSpbIds = assignedSpgs
      .where((es) => es.spbId != null)
      .map((es) => es.spbId!)
      .toSet();
    
    final List<SpbEntity> eventSpbs = allSpbs.where((s) => eventSpbIds.contains(s.id)).toList();

    final List<String> filteredAssignedSpgIds = _selectedSpbId != null
      ? assignedSpgs.where((es) => es.spbId == _selectedSpbId).map((es) => es.spgId).toList()
      : assignedSpgs.map((es) => es.spgId).toList();

    final List<SpgEntity> filteredSpgs = allSpgs.where((s) => filteredAssignedSpgIds.contains(s.id)).toList();

    final warehouseInfo = _selectedProductId != null
      ? _calculateWarehouseStock(stockState, _selectedProductId!)
      : null;

    final spgStockInfo = _selectedSpgId != null && _selectedProductId != null
      ? _calculateSpgStock(stockState, salesState, _selectedSpgId!, _selectedProductId!)
      : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADD_TOPUP',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),

        Text('SPB_OPTIONAL', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
        const SizedBox(height: 8),
        DropdownSearch<SpbEntity>(
          selectedItem: _selectedSpbId != null 
            ? eventSpbs.where((s) => s.id == _selectedSpbId).firstOrNull 
            : null,
          items: (f, cs) => eventSpbs.toList(),
          itemAsString: (spb) => spb.name.toUpperCase(),
          compareFn: (a, b) => a.id == b.id,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'ALL_SPGS',
              hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                hintText: 'SEARCH_SPB',
                hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            menuProps: MenuProps(
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            itemBuilder: (context, spb, isDisabled, isSelected) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  spb.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              );
            },
          ),
          onSelected: (spb) {
            setState(() {
              _selectedSpbId = spb?.id;
              _selectedSpgId = null;
            });
          },
        ),
        const SizedBox(height: 16),

        Text('SPG', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
        const SizedBox(height: 8),
        DropdownSearch<SpgEntity>(
          selectedItem: _selectedSpgId != null 
            ? filteredSpgs.where((s) => s.id == _selectedSpgId).firstOrNull 
            : null,
          items: (f, cs) => filteredSpgs.toList(),
          itemAsString: (spg) => spg.name.toUpperCase(),
          compareFn: (a, b) => a.id == b.id,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'SELECT_SPG',
              hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                hintText: 'SEARCH_SPG',
                hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            menuProps: MenuProps(
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            itemBuilder: (context, spg, isDisabled, isSelected) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  spg.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              );
            },
          ),
          onSelected: (spg) {
            setState(() => _selectedSpgId = spg?.id);
          },
        ),
        const SizedBox(height: 16),

        Text('PRODUCT', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
        const SizedBox(height: 8),
        DropdownSearch<ProductEntity>(
          selectedItem: _selectedProductId != null 
            ? products.where((p) => p.id == _selectedProductId).firstOrNull 
            : null,
          items: (f, cs) => products.toList(),
          itemAsString: (p) {
            final warehouse = _calculateWarehouseStock(stockState, p.id);
            final badge = warehouse <= 0 ? ' (OUT_OF_STOCK)' : ' (WH: $warehouse)';
            return '${p.name.toUpperCase()}$badge';
          },
          compareFn: (a, b) => a.id == b.id,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'SELECT_PRODUCT',
              hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                hintText: 'SEARCH_PRODUCT',
                hintStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            menuProps: MenuProps(
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            itemBuilder: (context, p, isDisabled, isSelected) {
              final warehouse = _calculateWarehouseStock(stockState, p.id);
              final badge = warehouse <= 0 ? ' (OUT_OF_STOCK)' : ' (WH: $warehouse)';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  '${p.name.toUpperCase()}$badge',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: warehouse <= 0 ? AppColors.error : AppColors.onSurface,
                  ),
                ),
              );
            },
          ),
          onSelected: (p) {
            setState(() => _selectedProductId = p?.id);
          },
        ),
        const SizedBox(height: 16),

        if (spgStockInfo != null || warehouseInfo != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border.all(color: AppColors.surfaceContainerHigh),
            ),
            child: Row(
              children: [
                if (spgStockInfo != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SPG_STOCK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('$spgStockInfo units', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                if (warehouseInfo != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WAREHOUSE_AVAILABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('$warehouseInfo units', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: warehouseInfo <= 0 ? AppColors.error : AppColors.success)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        Text('QTY_TO_ADD', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() => _qty = int.tryParse(value) ?? 0);
          },
          decoration: const InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(fontWeight: FontWeight.w900),
          ),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),

        if (_qty > 0 && warehouseInfo != null && _qty > warehouseInfo)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Text(
                  'EXCEEDS_WAREHOUSE: $warehouseInfo',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.error),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveTopup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onSuccess,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSpbId = null;
                    _selectedSpgId = null;
                    _selectedProductId = null;
                    _qty = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.onSurface,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  side: BorderSide(color: AppColors.surfaceContainerHigh),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK_ACTIONS',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1),
        ),
        const SizedBox(height: 12),

        _buildActionCard(
          context,
          icon: Icons.inventory_outlined,
          title: 'INITIAL DISTRIBUTION',
          subtitle: 'Set initial stock for SPGs',
          color: AppColors.primary,
          onTap: () => context.pushNamed('bulk_initial', pathParameters: {'eventId': widget.eventId}),
        ),
        const SizedBox(height: 8),

        _buildActionCard(
          context,
          icon: Icons.add_circle_outline,
          title: 'RESUPPLY',
          subtitle: 'Bulk topup to SPGs',
          color: AppColors.secondary,
          onTap: () => context.pushNamed('bulk_topup', pathParameters: {'eventId': widget.eventId}),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(
                    subtitle.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}