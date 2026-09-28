import 'package:flutter/material.dart';
import '../config/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11.5,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Draft':
        return AppColors.statusDraft;
      case 'Submitted':
        return AppColors.statusSubmitted;
      case 'Under Verification':
        return AppColors.statusVerification;
      case 'Accepted':
        return AppColors.statusAccepted;
      case 'Rejected':
        return AppColors.statusRejected;
      case 'Assigned':
        return AppColors.statusAssigned;
      case 'Under Investigation':
        return AppColors.statusInvestigation;
      case 'Action Required':
        return AppColors.statusActionRequired;
      case 'More Information Required':
        return AppColors.statusMoreInfo;
      case 'Resolved':
        return AppColors.statusResolved;
      case 'Closed':
        return AppColors.statusClosed;
      case 'Reopened':
        return AppColors.statusReopened;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'Draft':
        return Icons.edit_note_rounded;
      case 'Submitted':
        return Icons.send_rounded;
      case 'Under Verification':
        return Icons.verified_user_outlined;
      case 'Accepted':
        return Icons.check_circle_outline_rounded;
      case 'Rejected':
        return Icons.cancel_outlined;
      case 'Assigned':
        return Icons.assignment_ind_outlined;
      case 'Under Investigation':
        return Icons.search_rounded;
      case 'Action Required':
        return Icons.warning_amber_rounded;
      case 'More Information Required':
        return Icons.help_outline_rounded;
      case 'Resolved':
        return Icons.task_alt_rounded;
      case 'Closed':
        return Icons.lock_outline_rounded;
      case 'Reopened':
        return Icons.replay_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: fontSize + 2, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
