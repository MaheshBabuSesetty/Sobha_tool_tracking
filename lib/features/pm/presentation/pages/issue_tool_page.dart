import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/presentation/blocs/pm_bloc.dart';

class IssueToolPage extends StatefulWidget {
  const IssueToolPage({super.key});

  @override
  State<IssueToolPage> createState() => _IssueToolPageState();
}

class _IssueToolPageState extends State<IssueToolPage> {
  List<PmRequestEntity>? _requests;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PmBloc>();
    final state = bloc.state;
    if (state is PmRequestsLoaded) {
      _requests = state.requests;
    } else {
      bloc.add(const PmRequestsLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<PmBloc, PmState>(
        listenWhen: (_, curr) =>
            curr is PmRequestsLoaded || curr is PmError,
        listener: (context, state) {
          if (state is PmRequestsLoaded) {
            setState(() => _requests = state.requests);
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
              'Issue Tool Requests',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => context
                    .read<PmBloc>()
                    .add(const PmRequestsLoadRequested()),
              ),
            ],
          ),
          body: _requests == null
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : _RequestList(
                  requests: _requests!,
                  onRefresh: () => context
                      .read<PmBloc>()
                      .add(const PmRequestsLoadRequested()),
                ),
        ),
      );
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.requests, required this.onRefresh});

  final List<PmRequestEntity> requests;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final pendingCount = requests.where((r) => r.isActionable).length;
    return Column(
      children: [
        if (pendingCount > 0)
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        '$pendingCount Pending Request${pendingCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const TextSpan(
                    text: ' waiting for issue',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: requests.isEmpty
              ? const Center(
                  child: Text(
                    'No pending requests',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _RequestCard(
                    request: requests[index],
                    onTap: () => context.push(
                      '/home/issue-tool/${requests[index].id}',
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onTap});

  final PmRequestEntity request;
  final VoidCallback onTap;

  static final _dateFmt = DateFormat('d-MMM-yyyy');

  @override
  Widget build(BuildContext context) {
    final isActionable = request.isActionable;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.requestNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              request.requestedBy,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // Detail rows
            _DetailRow(label: 'Site:', value: request.siteName),
            _DetailRow(label: 'Priority:', value: request.priority),
            _DetailRow(
              label: 'Tools:',
              value:
                  '${request.itemsRemaining} remaining / ${request.itemsTotal} total',
            ),
            _DetailRow(
              label: 'Created:',
              value: _dateFmt.format(request.createdAt.toLocal()),
            ),

            const SizedBox(height: 18),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isActionable ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isActionable ? AppColors.primary : AppColors.grey300,
                  foregroundColor:
                      isActionable ? AppColors.onPrimary : AppColors.grey600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isActionable ? 'View & Issue' : 'Fulfilled',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isActionable
                        ? AppColors.onPrimary
                        : AppColors.grey600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
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
                  fontWeight: FontWeight.w500,
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
          AppColors.primary.withValues(alpha: 0.15),
          AppColors.primaryDark,
        ),
      'Partially Fulfilled' => (
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100),
        ),
      _ => (
          AppColors.successContainer,
          AppColors.success,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
