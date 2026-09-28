import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/complaint_model.dart';
import 'api_client.dart';

class DocumentService {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<File?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  static Future<File?> pickImage(
      {ImageSource source = ImageSource.gallery}) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  static Future<ComplaintDocument> uploadDocument(
      int complaintId, File file) async {
    try {
      final fileName = p.basename(file.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await ApiClient().post(
        '/complaints/$complaintId/documents',
        data: formData,
      );

      if (response.data['success'] == true) {
        return ComplaintDocument.fromJson(response.data['document']);
      } else {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> downloadAndOpen(int documentId, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = p.join(tempDir.path, fileName);

      final response = await ApiClient().dio.download(
            '/documents/$documentId',
            savePath,
          );

      if (response.statusCode == 200) {
        await OpenFilex.open(savePath);
      } else {
        throw Exception('Failed to download document');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> deleteDocument(int documentId) async {
    try {
      final response = await ApiClient().delete('/documents/$documentId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Deletion failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }
}
