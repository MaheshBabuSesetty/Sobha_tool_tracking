import 'package:flutter/material.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';

class IssueSuccessPage extends StatefulWidget {
  const IssueSuccessPage({super.key, required this.response});

  final ActionResponseEntity response;

  @override
  State<IssueSuccessPage> createState() => _IssueSuccessPageState();
}

class _IssueSuccessPageState extends State<IssueSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Check icon ──────────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 64,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Title ───────────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'Tool Issued!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    widget.response.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryDark,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Details card ────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.build_circle_outlined,
                          label: 'Tool ID',
                          value: '#${widget.response.toolId}',
                        ),
                        if (widget.response.requestStatus != null) ...[
                          const _Divider(),
                          _DetailRow(
                            icon: Icons.assignment_turned_in_outlined,
                            label: 'Request Status',
                            value: widget.response.requestStatus!,
                            valueColor: _statusColor(
                              widget.response.requestStatus!,
                            ),
                          ),
                        ],
                        if (widget.response.gatePassNumber != null) ...[
                          const _Divider(),
                          _DetailRow(
                            icon: Icons.confirmation_number_outlined,
                            label: 'Gate Pass',
                            value: widget.response.gatePassNumber!,
                            valueColor: AppColors.primary,
                          ),
                        ],
                        const _Divider(),
                        _DetailRow(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Tool Status',
                          value: widget.response.newStatus,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Done button ─────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );

  Color _statusColor(String status) => switch (status) {
        'Fulfilled' => AppColors.success,
        'Partially Fulfilled' => AppColors.warning,
        _ => AppColors.primary,
      };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(color: Color(0xFF3A3A50), height: 1),
      );
}