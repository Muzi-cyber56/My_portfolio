import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  ApiService._();
  static final instance = ApiService._();
  String? token;
  final expired = ValueNotifier(false);
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  Future<dynamic> request(
    String method,
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final req = http.Request(method, Uri.parse('${ApiConfig.baseUrl}$path'));
      req.headers.addAll(headers);
      if (data != null) req.body = jsonEncode(data);
      final response = await http.Response.fromStream(
        await req.send().timeout(const Duration(seconds: 20)),
      ).timeout(const Duration(seconds: 30));
      return _decode(response);
    } on TimeoutException {
      throw ApiException('The server took too long. Please retry.');
    } on http.ClientException {
      throw ApiException(
        'Cannot connect to the API. Check the server and API_BASE_URL.',
      );
    }
  }

  dynamic _decode(http.Response r) {
    if (r.statusCode == 401) {
      if (token != null) {
        token = null;
        expired.value = true;
      }
      throw ApiException('Please sign in. Your session may have expired.');
    }
    if (r.statusCode >= 400) {
      dynamic body;
      try {
        body = jsonDecode(r.body);
      } catch (_) {}
      final errors = body is Map ? body['errors'] : null;
      throw ApiException(
        errors is Map
            ? errors.values.expand((e) => e is List ? e : [e]).join('\n')
            : body is Map && body['title'] != null
            ? body['title']
            : r.statusCode == 429
            ? 'Too many requests. Please wait a minute.'
            : 'Request failed (${r.statusCode}).',
      );
    }
    return r.body.isEmpty ? null : jsonDecode(r.body);
  }

  Future<dynamic> upload(
    String path,
    String caseId,
    String name,
    Uint8List bytes,
    String source,
  ) async {
    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$path'),
      );
      if (token != null) req.headers['Authorization'] = 'Bearer $token';
      req.fields.addAll({'caseId': caseId, 'source': source});
      req.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: name),
      );
      return _decode(
        await http.Response.fromStream(
          await req.send().timeout(const Duration(seconds: 45)),
        ).timeout(const Duration(seconds: 45)),
      );
    } on TimeoutException {
      throw ApiException(
        'Upload timed out. Check the evidence list before retrying.',
      );
    } on http.ClientException {
      throw ApiException('Upload failed. Check your connection.');
    }
  }

  Future<Uint8List> download(String path) async {
    try {
      final r = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (r.statusCode >= 400) _decode(r);
      return r.bodyBytes;
    } on TimeoutException {
      throw ApiException('Download timed out.');
    } on http.ClientException {
      throw ApiException('Cannot download the file. Check your connection.');
    }
  }
}
