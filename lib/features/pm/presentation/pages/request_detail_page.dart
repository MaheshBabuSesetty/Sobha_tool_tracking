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
          backgroundColor: const Color(0xFFF2F2F2),
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
              final canScan = detail.status == 'PM Approved';
              final canIssue = _matchedItemIds.isNotEmpty;
              return _DetailBody(
                detail: detail,
                matchedItemIds: _matchedItemIds,
                onScan: canScan ? () => _openRfidScanner(detail) : null,
                onIssue: canIssue ? () => _showIssuePicker(detail) : null,
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
  Widget build(BuildContext context) {
    final totalItems = detail.items.fold(0, (s, i) => s + i.quantity);
    final totalIssued = detail.items.fold(0, (s, i) => s + i.issued);
    final totalRemaining = detail.items.fold(0, (s, i) => s + i.remaining);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Summary card ────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Request Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          _PriorityChip(priority: detail.priority),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 14),
                      _InfoRow(
                        label: 'Request ID',
                        value: detail.requestNumber,
                      ),
                      _InfoRow(label: 'Site', value: detail.siteName),
                      _InfoRow(label: 'Status', value: detail.status),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _StatBox(
                            label: 'Total',
                            value: '$totalItems',
                            color: AppColors.textPrimary,
                          ),
                          _StatBox(
                            label: 'Issued',
                            value: '$totalIssued',
                            color: AppColors.success,
                          ),
                          _StatBox(
                            label: 'Remaining',
                            value: '$totalRemaining',
                            color: totalRemaining > 0
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Requested devices ────────────────────────────────────────
                Row(
                  children: [
                    const Text(
                      'Requested Devices',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${detail.items.length} item${detail.items.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...detail.items.map(
                  (item) => _DeviceItem(
                    item: item,
                    isMatched: matchedItemIds.contains(item.itemId),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom action bar ──────────────────────────────────────────────
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  // RFID scan button
                  Tooltip(
                    message: 'Scan RFID',
                    child: InkWell(
                      onTap: onScan,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: onScan != null
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: onScan != null
                                ? AppColors.primary
                                : AppColors.grey300,
                          ),
                        ),
                        child: Icon(
                          Icons.wifi_tethering_rounded,
                          color: onScan != null
                              ? AppColors.primary
                              : AppColors.grey400,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onIssue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.grey200,
                          foregroundColor: AppColors.onPrimary,
                          disabledForegroundColor: AppColors.grey500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Issue Tool',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority.toLowerCase()) {
      'high' => (AppColors.errorContainer, AppColors.error),
      'medium' => (AppColors.warningContainer, AppColors.warning),
      _ => (AppColors.grey100, AppColors.grey600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 90,
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
}

// ── Device item ──────────────────────────────────────────────────────────────

class _DeviceItem extends StatelessWidget {
  const _DeviceItem({required this.item, required this.isMatched});

  final PmRequestItemEntity item;
  final bool isMatched;

  @override
  Widget build(BuildContext context) {
    final available = item.availableStock.length;
    final hasStock = available > 0;
    final fulfilled = item.remaining == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(
        bottom: 10,
        left: isMatched ? 0 : 0,
      ),
      decoration: BoxDecoration(
        color: isMatched
            ? AppColors.primary.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMatched ? AppColors.primary : AppColors.divider,
          width: isMatched ? 2 : 1,
        ),
        boxShadow: isMatched
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Top row: icon + name + badges ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isMatched
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.build_rounded,
                    size: 20,
                    color:
                        isMatched ? AppColors.primary : AppColors.grey500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isMatched)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_tethering_rounded,
                          size: 10,
                          color: AppColors.onPrimary,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'RFID',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (fulfilled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Fulfilled',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────
          const Divider(height: 1, color: AppColors.divider),

          // ── Bottom row: stats + availability ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                _DeviceStat(
                  label: 'Requested',
                  value: '${item.quantity}',
                  color: AppColors.textPrimary,
                ),
                _DeviceStat(
                  label: 'Issued',
                  value: '${item.issued}',
                  color:
                      item.issued > 0 ? AppColors.success : AppColors.grey500,
                ),
                _DeviceStat(
                  label: 'Remaining',
                  value: '${item.remaining}',
                  color: item.remaining > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasStock
                        ? AppColors.successContainer
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: hasStock
                              ? AppColors.success
                              : AppColors.grey500,
                        ),
                      ),
                      Text(
                        'In Stock',
                        style: TextStyle(
                          fontSize: 10,
                          color: hasStock
                              ? AppColors.success
                              : AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceStat extends StatelessWidget {
  const _DeviceStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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