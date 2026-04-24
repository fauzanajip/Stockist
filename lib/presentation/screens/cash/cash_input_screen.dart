import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../blocs/cash_bloc/cash_bloc.dart';
import '../../blocs/cash_bloc/cash_event.dart';
import '../../blocs/cash_bloc/cash_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    final stripped = digitsOnly.replaceAll(RegExp(r'^0+(?!$)'), '');
    if (stripped.isEmpty) return const TextEditingValue(text: '0');

    final formatted = _formatWithThousands(stripped);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithThousands(String digits) {
    final buffer = StringBuffer();
    final length = digits.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}

class CashInputScreen extends StatefulWidget {
  final String eventId;
  final String spgId;

  const CashInputScreen({
    super.key,
    required this.eventId,
    required this.spgId,
  });

  @override
  State<CashInputScreen> createState() => _CashInputScreenState();
}

class _CashInputScreenState extends State<CashInputScreen> {
  final _cashController = TextEditingController();
  final _qrisController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _cashController.addListener(() => setState(() {}));
    _qrisController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cashController.dispose();
    _qrisController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<SpgBloc>().add(LoadAllSpqs());
    context.read<EventProductBloc>().add(
      LoadAvailableProducts(eventId: widget.eventId),
    );
    context.read<SalesBloc>().add(
      LoadSales(eventId: widget.eventId, spgId: widget.spgId),
    );
    context.read<CashBloc>().add(
      LoadCashRecord(eventId: widget.eventId, spgId: widget.spgId),
    );
  }

  void _initControllersFromState() {
    final cashState = context.read<CashBloc>().state;
    if (_cashController.text.isEmpty && cashState.cashReceived > 0) {
      _cashController.text = _formatThousands(cashState.cashReceived.toInt());
    }
    if (_qrisController.text.isEmpty && cashState.qrisReceived > 0) {
      _qrisController.text = _formatThousands(cashState.qrisReceived.toInt());
    }
  }

  String _formatThousands(int value) {
    if (value == 0) return '';
    final digits = value.toString();
    final buffer = StringBuffer();
    final length = digits.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  double _parseAmount(String text) {
    final stripped = text
        .replaceAll('.', '')
        .replaceAll(RegExp(r'^0+(?!$)'), '');
    return double.tryParse(stripped) ?? 0;
  }

  void _submitCash() async {
    final cash = _parseAmount(_cashController.text);
    final qris = _parseAmount(_qrisController.text);

    if (cash < 0 || qris < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nilai tidak boleh negatif'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      context.read<CashBloc>().add(
        UpdateCashRecord(
          eventId: widget.eventId,
          spgId: widget.spgId,
          cashReceived: cash,
          qrisReceived: qris,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data kas berhasil disimpan'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan kas: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMMERCE_LOGS: SETTLEMENT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'FINANCIAL AUDIT PROTOCOL',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.5),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'RECALCULATE_FINANCIALS'.toUpperCase(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surfaceContainerHigh, height: 1),
        ),
      ),
      body: BlocBuilder<SpgBloc, SpgState>(
        builder: (context, spgState) {
          String spgName = widget.spgId;
          if (spgState is SpqsLoaded) {
            final spg = spgState.spqs.firstWhere(
              (s) => s.id == widget.spgId,
              orElse: () => spgState.spqs.first,
            );
            spgName = spg.name;
          }

          return BlocBuilder<CashBloc, CashState>(
            builder: (context, cashState) {
              _initControllersFromState();
              return Column(
                children: [
                  _buildHeader(context, spgName),
                  Container(height: 1, color: AppColors.surfaceContainerHigh),
                  Expanded(child: _buildForm(context)),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildHeader(BuildContext context, String spgName) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, salesState) {
        return BlocBuilder<EventProductBloc, EventProductState>(
          builder: (context, productState) {
            double expectedCash = 0;

            if (productState is AvailableProductsLoaded &&
                salesState.salesByProduct.isNotEmpty) {
              for (final entry in salesState.salesByProduct.entries) {
                final product = productState.assignedProducts.firstWhere(
                  (p) => p.productId == entry.key,
                  orElse: () => productState.assignedProducts.first,
                );
                expectedCash += entry.value * product.price;
              }
            }

            return Container(
              width: double.infinity,
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AUDIT_TARGET_UNIT'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    spgName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPECTED_MISSION_REVENUE'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app_formatters.Formatters.formatCurrency(expectedCash).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.calculate_rounded, color: AppColors.onSurfaceVariant, size: 24),
                      ],
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

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountInput(
            label: 'PHYSICAL_CASH_TOTAL',
            controller: _cashController,
            iconPath: Icons.payments_outlined,
          ),
          const SizedBox(height: 24),
          _buildAmountInput(
            label: 'DIGITAL_QR_SETTLEMENT',
            controller: _qrisController,
            iconPath: Icons.qr_code_scanner_rounded,
          ),
          const SizedBox(height: 8),
          Text(
            'LOG DIGITAL TRANSACTIONS SEPARATELY FOR AUDIT TRAIL.'.toUpperCase(),
            style: const TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Text(
            'AUDIT_OBSERVATIONS (OPTIONAL)'.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'INPUT OBSERVATIONS...',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
              enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 40),
          _buildTotalSummary(context),
        ],
      ),
    );
  }

  Widget _buildAmountInput({
    required String label,
    required TextEditingController controller,
    required IconData iconPath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [_ThousandsFormatter()],
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.primary),
          decoration: InputDecoration(
            prefixText: 'RP ',
            prefixStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 16),
            suffixIcon: Icon(iconPath, color: AppColors.onSurfaceVariant, size: 20),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSummary(BuildContext context) {
    final cash = _parseAmount(_cashController.text);
    final qris = _parseAmount(_qrisController.text);
    final total = cash + qris;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PHYSICAL_TOTAL'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text(
                app_formatters.Formatters.formatCurrency(cash).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DIGITAL_TOTAL'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text(
                app_formatters.Formatters.formatCurrency(qris).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.surfaceContainerHigh),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTUAL_SETTLEMENT'.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              Text(
                app_formatters.Formatters.formatCurrency(total).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return BlocBuilder<CashBloc, CashState>(
      builder: (context, cashState) {
        final cash = _parseAmount(_cashController.text);
        final qris = _parseAmount(_qrisController.text);
        final hasInput = cash > 0 || qris > 0;
        final isExistingRecord = cashState.hasRecord;
        final canSave = isExistingRecord || hasInput;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_isSubmitting || !canSave) ? null : _submitCash,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isExistingRecord ? 'REVISE SETTLEMENT DATA' : 'EXECUTE SETTLEMENT PROTOCOL',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
            ),
          ),
        );
      },
    );
  }
}
