class CaseModel {
  final String id, caseNumber, title, description, status, priority;
  final DateTime createdAt;
  CaseModel.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      caseNumber = j['caseNumber'],
      title = j['title'],
      description = j['description'],
      status = j['status'],
      priority = j['priority'],
      createdAt = DateTime.parse(j['createdAt']);
}
