import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/pm_bloc.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/ui/rfid_scanner_page.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({super.key, required this.requestId});

  final String requestId;

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  int? get _id => int.tryParse(widget.requestId);

  @override
  void initState() {
    super.initState();
    if (_id != null) {
      context.read<PmBloc>().add(PmRequestDetailLoadRequested(_id!));
    }
  }

  void _issueStock(int toolId, int requestId) {
    context.read<PmBloc>().add(PmIssueToolRequested(
          requestId: requestId,
          toolId: toolId,
        ));
  }

  Future<void> _openRfidScanner(PmRequestDetailEntity detail) async {
    final result = await Navigator.push<RfidScanResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const RfidScannerPage(
          title: 'Scan to Issue',
          showDoneButton: true,
          minTags: 1,
        ),
      ),
    );
    if (result == null || result.tags.isEmpty || !mounted) return;

    final allStock =
        detail.items.expand((i) => i.availableStock).toList();

    for (final RfidTag tag in result.tags) {
      final epc = tag.epc.toUpperCase();
      AvailableStockEntity? matched;
      for (final stock in allStock) {
        if (stock.rfidTag.toUpperCase() == epc) {
          matched = stock;
          break;
        }
      }
      if (matched != null) {
        _issueStock(matched.id, detail.id);
        return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No matching tool found for scanned tag'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<PmBloc, PmState>(
      listenWhen: (_, curr) =>
          curr is PmActionSuccess || curr is PmError,
      listener: (context, state) {
        if (state is PmActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.requestStatus != null
                  ? 'Tool issued — request is now ${state.response.requestStatus}'
                  : state.response.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reload detail to reflect updated remaining counts
          context
              .read<PmBloc>()
              .add(PmRequestDetailLoadRequested(state.requestId));
        } else if (state is PmError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reload detail so UI stays usable
          if (_id != null) {
            context.read<PmBloc>().add(PmRequestDetailLoadRequested(_id!));
          }
        }
      },
      buildWhen: (_, curr) =>
          curr is PmLoading ||
          curr is PmRequestDetailLoaded ||
          curr is PmError,
      builder: (context, state) {
        if (_id == null) {
          return _scaffold(
            title: 'Request Details',
            status: null,
            body: const Center(child: Text('Invalid request ID')),
          );
        }

        if (state is PmLoading) {
          return _scaffold(
            title: 'Request Details',
            status: null,
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          );
        }

        if (state is PmError) {
          return _scaffold(
            title: 'Request Details',
            status: null,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<PmBloc>()
                        .add(PmRequestDetailLoadRequested(_id!)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! PmRequestDetailLoaded) {
          return _scaffold(
            title: 'Request Details',
            status: null,
            body: const SizedBox.shrink(),
          );
        }

        final detail = state.detail;
        return _scaffold(
          title: 'Request Details',
          status: detail.status,
          body: _DetailBody(
            detail: detail,
            onIssueTool: (toolId) => _issueStock(toolId, detail.id),
            onScanRfid: detail.isActionable
                ? () => _openRfidScanner(detail)
                : null,
          ),
        );
      },
    );

  Scaffold _scaffold({
    required String title,
    required String? status,
    required Widget body,
  }) =>
      Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: AppColors.sidebarBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          actions: [
            if (status != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _StatusBadge(status: status),
              ),
          ],
        ),
        body: body,
      );
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.detail,
    required this.onIssueTool,
    this.onScanRfid,
  });

  final PmRequestDetailEntity detail;
  final void Function(int toolId) onIssueTool;
  final VoidCallback? onScanRfid;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Request Summary ──────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _Row(label: 'Request ID:', value: detail.requestNumber),
                _Row(label: 'Site:', value: detail.siteName),
                _Row(label: 'Priority:', value: detail.priority),
                _Row(label: 'Status:', value: detail.status),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Line Items ───────────────────────────────────────────────
          const Text(
            'Requested Tools',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...detail.items.map(
            (item) => _ItemSection(
              item: item,
              onIssueTool: detail.isActionable ? onIssueTool : null,
            ),
          ),

          const SizedBox(height: 20),

          // ── Scan section ─────────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                const Text(
                  'Or scan an RFID tag to issue a tool directly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onScanRfid,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: onScanRfid != null
                          ? AppColors.primary
                          : AppColors.grey300,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_tethering_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  onScanRfid != null ? 'Tap to scan' : 'Scan not available',
                  style: TextStyle(
                    fontSize: 12,
                    color: onScanRfid != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
}

class _ItemSection extends StatelessWidget {
  const _ItemSection({required this.item, required this.onIssueTool});

  final PmRequestItemEntity item;
  final void Function(int toolId)? onIssueTool;

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.remaining} remaining  ·  ${item.issued} issued  ·  ${item.quantity} total',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Remaining badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: item.remaining > 0
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.successContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.remaining > 0
                        ? '${item.remaining} left'
                        : 'Done',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: item.remaining > 0
                          ? AppColors.primaryDark
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),

            if (item.availableStock.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              const Text(
                'Available in Stock',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...item.availableStock.map(
                (stock) => _StockRow(
                  stock: stock,
                  canIssue: onIssueTool != null && item.remaining > 0,
                  onIssue: onIssueTool != null
                      ? () => onIssueTool!(stock.id)
                      : null,
                ),
              ),
            ] else if (item.remaining > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFE65100), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No matching tools in stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
}

class _StockRow extends StatelessWidget {
  const _StockRow({
    required this.stock,
    required this.canIssue,
    required this.onIssue,
  });

  final AvailableStockEntity stock;
  final bool canIssue;
  final VoidCallback? onIssue;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.rfidTag,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${stock.serialNumber}  ·  ${stock.condition}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: canIssue ? onIssue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canIssue ? AppColors.primary : AppColors.grey300,
                  foregroundColor:
                      canIssue ? Colors.white : AppColors.grey600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Issue',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'PM Approved' => (
          AppColors.primary.withValues(alpha: 0.2),
          AppColors.primaryDark,
        ),
      'Partially Fulfilled' => (
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100),
        ),
      _ => (AppColors.successContainer, AppColors.success),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
