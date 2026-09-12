class Investigation {
  final String id, label;
  Investigation.fromJson(Map<String, dynamic> j)
    : id = j['id'],
      label = j['label'];
}
