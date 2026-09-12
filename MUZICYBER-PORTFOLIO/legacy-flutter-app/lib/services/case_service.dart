import '../models/case_model.dart';
import '../models/finding.dart';
import 'api_service.dart';

class CaseService {
  final api = ApiService.instance;
  Future<List<CaseModel>> list() async =>
      ((await api.request('GET', '/api/cases')) as List)
          .map((j) => CaseModel.fromJson(j))
          .toList();
  Future<CaseModel> create(Map<String, dynamic> data) async =>
      CaseModel.fromJson(await api.request('POST', '/api/cases', data));
  Future<CaseModel> update(String id, Map<String, dynamic> data) async =>
      CaseModel.fromJson(await api.request('PUT', '/api/cases/$id', data));
  Future<void> delete(String id) async {
    await api.request('DELETE', '/api/cases/$id');
  }

  Future<List<Finding>> findings(String id) async =>
      ((await api.request('GET', '/api/cases/$id/findings')) as List)
          .map((j) => Finding.fromJson(j))
          .toList();
}
