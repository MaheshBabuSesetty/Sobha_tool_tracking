import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/pm_bloc.dart';
import 'package:power_tool_tracking/features/pm/presentation/pages/issue_success_page.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/ui/rfid_scanner_page.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({super.key, required this.requestId});

  final String requestId;

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  int? get _id => int.tryParse(widget.requestId);
  Set<int> _matchedItemIds = {};

  @override
  void initState() {
    super.initState();
    if (_id != null) {
      context.read<PmBloc>().add(PmRequestDetailLoadRequested(_id!));
    }
  }

  Future<void> _openRfidScanner(PmRequestDetailEntity detail) async {
    final result = await Navigator.push<RfidScanResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const RfidScannerPage(
          title: 'Scan to Issue',
          minTags: 1,
        ),
      ),
    );
    if (result == null || result.tags.isEmpty || !mounted) {
      return;
    }

    final allStocks = detail.items
        .expand((item) => item.availableStock)
        .toList();

    // For each scanned tag, find matching device items and dispatch an issue event
    final matched = <int>{};
    for (final tag in result.tags) {
      final epc = tag.epc.toUpperCase();
      final item = detail.items.where(
        (i) => i.availableStock.any(
          (s) => s.rfidTag.toUpperCase() == epc,
        ),
      ).firstOrNull;
      if (item != null) {
        matched.add(item.itemId);
      }
      context.read<PmBloc>().add(PmScanAndIssueRequested(
            rfidCode: tag.epc,
            requestId: detail.id,
            availableStocks: allStocks,
          ),);
    }

    setState(() => _matchedItemIds = matched);
  }

  void _showIssuePicker(PmRequestDetailEntity detail) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IssuePickerSheet(
        detail: detail,
        onIssue: (toolId) {
          Navigator.pop(context);
          context.read<PmBloc>().add(PmIssueToolRequested(
                requestId: detail.id,
                toolId: toolId,
              ),);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<PmBloc, PmState>(
        listenWhen: (_, curr) =>
            curr is PmActionSuccess || curr is PmScanNoMatch || curr is PmError,
        listener: (context, state) {
          if (state is PmActionSuccess) {
            setState(() => _matchedItemIds = {});
            final requestId = state.requestId;
            final response = state.response;
            final bloc = context.read<PmBloc>();
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => IssueSuccessPage(response: response),
              ),
            ).then((_) {
              if (!mounted) {
                return;
              }
              bloc.add(PmRequestDetailLoadRequested(requestId));
            });
          } else if (state is PmScanNoMatch) {
            setState(() => _matchedItemIds = {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No matching tool found for scanned tag'),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is PmError) {
            setState(() => _matchedItemIds = {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppColors.sidebarBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: const Text(
              'Request Details',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            actions: [
              BlocSelector<PmBloc, PmState, String?>(
                selector: (state) =>
                    state is PmRequestDetailLoaded ? state.detail.status : null,
                builder: (context, status) {
                  if (status == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _StatusBadge(status: status),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<PmBloc, PmState>(
            buildWhen: (_, curr) =>
                curr is PmLoading ||
                curr is PmRequestDetailLoaded ||
                curr is PmError,
            builder: (context, state) {
              if (_id == null) {
                return const Center(
                  child: Text(
                    'Invalid request ID',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              if (state is PmLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                );
              }
              if (state is PmError) {
                return _ErrorBody(
                  message: state.message,
                  onRetry: () => context
                      .read<PmBloc>()
                      .add(PmRequestDetailLoadRequested(_id!)),
                );
              }
              if (state is! PmRequestDetailLoaded) {
                return const SizedBox.shrink();
              }
              final detail = state.detail;
              final hasStock = detail.isActionable &&
                  detail.items.any((i) => i.availableStock.isNotEmpty);
              return _DetailBody(
                detail: detail,
                matchedItemIds: _matchedItemIds,
                onScan: hasStock ? () => _openRfidScanner(detail) : null,
                onIssue: hasStock ? () => _showIssuePicker(detail) : null,
              );
            },
          ),
        ),
      );
}

// ── Detail body ──────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.detail,
    required this.onScan,
    required this.onIssue,
    required this.matchedItemIds,
  });

  final PmRequestDetailEntity detail;
  final VoidCallback? onScan;
  final VoidCallback? onIssue;
  final Set<int> matchedItemIds;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary card ────────────────────────────────────────
                  _WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Request Summary',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                            label: 'Request ID:',
                            value: detail.requestNumber,),
                        _InfoRow(label: 'Site:', value: detail.siteName),
                        _InfoRow(label: 'Priority:', value: detail.priority),
                        _InfoRow(label: 'Status:', value: detail.status),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Requested devices ───────────────────────────────────
                  const Text(
                    'Requested Devices',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...detail.items.map(
                    (item) => _DeviceItem(
                      item: item,
                      isMatched: matchedItemIds.contains(item.itemId),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Scan card ───────────────────────────────────────────
                  _WhiteCard(
                    child: Column(
                      children: [
                        const Text(
                          'Manually scan each device one by one.\nStop scanning once done.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: onScan,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: onScan != null
                                  ? AppColors.primary
                                  : AppColors.grey300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wifi_tethering_rounded,
                              color: onScan != null
                                  ? Colors.white
                                  : AppColors.grey500,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Issue Tool button ─────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onIssue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey300,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Issue Tool',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

// ── Device item ──────────────────────────────────────────────────────────────

class _DeviceItem extends StatelessWidget {
  const _DeviceItem({required this.item, required this.isMatched});

  final PmRequestItemEntity item;
  final bool isMatched;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isMatched ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isMatched
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isMatched
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isMatched
                          ? AppColors.onPrimaryContainer
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested Qty: ${item.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isMatched
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isMatched)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 12, color: AppColors.onPrimary,),
                    SizedBox(width: 4),
                    Text(
                      'Matched',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

// ── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}

// ── Shared widgets ───────────────────────────────────────────────────────────

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
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

// ── Issue picker sheet ───────────────────────────────────────────────────────

class _IssuePickerSheet extends StatelessWidget {
  const _IssuePickerSheet({required this.detail, required this.onIssue});

  final PmRequestDetailEntity detail;
  final void Function(int toolId) onIssue;

  @override
  Widget build(BuildContext context) {
    final itemsWithStock =
        detail.items.where((i) => i.availableStock.isNotEmpty).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Tool to Issue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.requestNumber,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: itemsWithStock.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final item = itemsWithStock[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...item.availableStock.map(
                      (stock) => _StockTile(
                        stock: stock,
                        onTap: () => onIssue(stock.id),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  const _StockTile({required this.stock, required this.onTap});

  final AvailableStockEntity stock;
  final VoidCallback onTap;

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to issue this tool?'),
            const SizedBox(height: 12),
            _ConfirmRow(label: 'Serial No', value: stock.serialNumber),
            _ConfirmRow(label: 'RFID Tag', value: stock.rfidTag),
            _ConfirmRow(label: 'Condition', value: stock.condition),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
            ),
            child: const Text('Issue'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _confirm(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3A3A50)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'S/N: ${stock.serialNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'RFID: ${stock.rfidTag}  •  ${stock.condition}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Issue',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
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
      'PM Approved' || 'Pending Issue' => (
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.primaryDark,
        ),
      'Partially Fulfilled' => (
          const Color(0x33F57F17),
          AppColors.warning,
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