import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/report_model.dart';
import 'api_client.dart';

class ReportService {
  static Future<ReportSummary> getReportSummary({
    String? fromDate,
    String? toDate,
    int? hospitalId,
    String? district,
    int? categoryId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;
      if (hospitalId != null) queryParams['hospital_id'] = hospitalId;
      if (district != null) queryParams['district'] = district;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (status != null && status != 'All') queryParams['status'] = status;

      final response = await ApiClient()
          .get('/reports/summary', queryParameters: queryParams);

      if (response.data['success'] == true) {
        return ReportSummary.fromJson(response.data['summary']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load report summary');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }

  static Future<void> exportReport(String format) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final ext =
          format.toLowerCase() == 'excel' ? 'xlsx' : format.toLowerCase();
      final fileName =
          'TCH_Grievance_Report_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savePath = p.join(tempDir.path, fileName);

      final response = await ApiClient().dio.download(
            '/reports/export/${format.toLowerCase()}',
            savePath,
          );

      if (response.statusCode == 200) {
        await OpenFilex.open(savePath);
      } else {
        throw Exception('Export download failed');
      }
    } catch (e) {
      throw Exception(ApiClient().formatError(e));
    }
  }
}
