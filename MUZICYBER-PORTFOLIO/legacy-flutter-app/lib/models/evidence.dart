class Evidence {
  final String id,
      caseId,
      originalName,
      sha256,
      source,
      integrityStatus,
      metadata;
  final int size;
  Evidence.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      caseId = j['caseId'],
      originalName = j['originalName'],
      sha256 = j['sha256'],
      source = j['source'],
      integrityStatus = j['integrityStatus'],
      metadata = j['metadata'],
      size = j['size'];
}
