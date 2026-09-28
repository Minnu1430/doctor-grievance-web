import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../config/constants.dart';
import '../services/document_service.dart';

class DocumentTile extends StatelessWidget {
  final ComplaintDocument document;
  final bool canDelete;
  final VoidCallback? onDelete;

  const DocumentTile({
    super.key,
    required this.document,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = document.isPdf;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image,
              color: isPdf ? Colors.red.shade700 : Colors.blue.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${document.formattedSize} • Uploaded by ${document.uploaderName ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded,
                color: AppColors.primary, size: 22),
            tooltip: 'View / Download',
            onPressed: () =>
                DocumentService.downloadAndOpen(document.id, document.fileName),
          ),
          if (canDelete)
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              tooltip: 'Delete Document',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
