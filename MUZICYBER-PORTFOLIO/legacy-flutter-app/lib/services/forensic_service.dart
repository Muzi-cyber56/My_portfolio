import 'dart:typed_data';
import '../models/evidence.dart';
import 'api_service.dart';

class ForensicService {
  Future<List<Evidence>> list(String caseId) async =>
      ((await ApiService.instance.request('GET', '/api/evidence/$caseId'))
              as List)
          .map((j) => Evidence.fromJson(j))
          .toList();
  Future<Evidence> upload(
    String caseId,
    String name,
    Uint8List bytes,
    String source, {
    bool imageOnly = false,
  }) async => Evidence.fromJson(
    await ApiService.instance.upload(
      imageOnly ? '/api/forensics/image' : '/api/evidence',
      caseId,
      name,
      bytes,
      source,
    ),
  );
  Future<Evidence> verify(Evidence e) async => Evidence.fromJson(
    await ApiService.instance.request(
      'POST',
      '/api/evidence/${e.caseId}/${e.id}/verify',
    ),
  );
  Future<Map<String, dynamic>> cnic(String value) async => await ApiService
      .instance
      .request('POST', '/api/forensics/cnic', {'value': value});
}
