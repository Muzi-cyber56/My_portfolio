import 'dart:typed_data';
import 'api_service.dart';

class ReportService {
  Future<List<dynamic>> list(String id) async =>
      await ApiService.instance.request('GET', '/api/reports/case/$id');
  Future<Map<String, dynamic>> generate(String id) async =>
      await ApiService.instance.request('POST', '/api/reports/$id');
  Future<Uint8List> download(String id) =>
      ApiService.instance.download('/api/reports/$id');
}
