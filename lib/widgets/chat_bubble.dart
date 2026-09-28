import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint_model.dart';
import '../config/constants.dart';

class ChatBubble extends StatelessWidget {
  final ComplaintMessage message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(message.createdAt);
    } catch (_) {}

    final formattedTime = parsedDate != null
        ? DateFormat('hh:mm a, dd MMM').format(parsedDate.toLocal())
        : message.createdAt;

    final isInternal = message.isInternalNote;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isInternal
              ? Colors.amber.shade100
              : (isMe ? AppColors.primary : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: Border.all(
            color: isInternal
                ? Colors.amber.shade400
                : (isMe ? AppColors.primary : AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isInternal)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 12, color: Colors.amber.shade900),
                  const SizedBox(width: 4),
                  Text(
                    'INTERNAL INVESTIGATION NOTE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            if (!isMe || isInternal) ...[
              const SizedBox(height: 2),
              Text(
                '${message.senderName ?? 'User'} (${message.senderRole ?? 'Officer'})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isInternal
                      ? Colors.amber.shade900
                      : (isMe ? Colors.white70 : AppColors.secondary),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.message,
              style: TextStyle(
                fontSize: 14,
                color: isInternal
                    ? Colors.brown.shade900
                    : (isMe ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 10,
                color: isInternal
                    ? Colors.brown.shade600
                    : (isMe ? Colors.white70 : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
