import 'api_service.dart';

class OsintService {
  Future<Map<String, dynamic>> lookup(
    String type,
    String caseId,
    String value,
  ) async => await ApiService.instance.request('POST', '/api/osint/$type', {
    'caseId': caseId,
    'value': value,
  });
  Future<Map<String, dynamic>> correlation(String caseId) async =>
      await ApiService.instance.request('GET', '/api/correlation/$caseId');
}
