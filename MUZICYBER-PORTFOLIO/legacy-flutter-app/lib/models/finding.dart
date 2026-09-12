class Finding {
  final String type, value, sourceUrl;
  final double confidence;
  Finding.fromJson(Map<String, dynamic> j)
    : type = j['findingType'],
      value = j['value'],
      sourceUrl = j['sourceUrl'] ?? '',
      confidence = (j['confidence'] as num).toDouble();
}
