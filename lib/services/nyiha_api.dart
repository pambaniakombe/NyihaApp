import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => message;
}

/// REST client for [kApiBaseUrl] + [kApiV1Prefix].
class NyihaApi {
  NyihaApi._();

  static String get _root => '$kApiBaseUrl$kApiV1Prefix';

  /// Build a full URL for chat media returned by the API (`path` or absolute URL).
  static String resolveChatMediaUrl(String? stored) {
    if (stored == null || stored.isEmpty) return '';
    final s = stored.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    final base = kApiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final p = s.startsWith('/') ? s : '/$s';
    return '$base$p';
  }

  /// Profile avatars from `/api/v1/me/media/...` — same resolution as [resolveChatMediaUrl].
  static String resolveAvatarUrl(String? stored) => resolveChatMediaUrl(stored);

  /// `POST /me/avatar` — multipart `file`; returns `{ id, avatarUrl }`.
  static Future<Map<String, dynamic>> uploadMemberAvatar({
    required List<int> bytes,
    String filename = 'avatar.jpg',
    String? bearer,
  }) async {
    final uri = Uri.parse('$_root/me/avatar');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Accept'] = 'application/json';
    if (bearer != null && bearer.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $bearer';
    }
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _decodeMap(res);
  }

  static Map<String, String> _headers({String? bearer}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (bearer != null && bearer.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearer';
    }
    return h;
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? bearer,
  }) async {
    final uri = Uri.parse('$_root$path');
    final res = await http.post(uri, headers: _headers(bearer: bearer), body: jsonEncode(body));
    try {
      return _decodeMap(res);
    } on ApiException {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    String? bearer,
  }) async {
    final uri = Uri.parse('$_root$path');
    final res = await http.patch(uri, headers: _headers(bearer: bearer), body: jsonEncode(body));
    try {
      return _decodeMap(res);
    } on ApiException {
      rethrow;
    }
  }

  /// `POST /chat/upload` — image or audio; returns `{ path, mediaKind }`.
  static Future<Map<String, dynamic>> uploadChatMediaMultipart({
    required http.MultipartFile file,
    String? bearer,
  }) async {
    final uri = Uri.parse('$_root/chat/upload');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Accept'] = 'application/json';
    if (bearer != null && bearer.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $bearer';
    }
    req.files.add(file);
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _decodeMap(res);
  }

  static Future<String?> uploadChatBytes({
    required List<int> bytes,
    required String filename,
    String? bearer,
  }) async {
    final map = await uploadChatMediaMultipart(
      file: http.MultipartFile.fromBytes('file', bytes, filename: filename),
      bearer: bearer,
    );
    final p = map['path'];
    return p is String && p.isNotEmpty ? p : null;
  }

  static Future<String?> uploadChatFilePath({
    required String path,
    required String filename,
    String? bearer,
  }) async {
    final file = await http.MultipartFile.fromPath('file', path, filename: filename);
    final map = await uploadChatMediaMultipart(file: file, bearer: bearer);
    final p = map['path'];
    return p is String && p.isNotEmpty ? p : null;
  }

  static Future<List<dynamic>> getList(String path, {String? bearer}) async {
    final uri = Uri.parse('$_root$path');
    final res = await http.get(uri, headers: _headers(bearer: bearer));
    dynamic j;
    try {
      j = jsonDecode(res.body);
    } catch (_) {
      if (res.statusCode >= 400) {
        throw ApiException(res.statusCode, res.body.isNotEmpty ? res.body : 'Request failed');
      }
      throw ApiException(res.statusCode, 'Invalid response');
    }
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, _errMsg(j));
    }
    if (j is! List) throw ApiException(res.statusCode, 'Invalid response');
    return j;
  }

  static Future<Map<String, dynamic>> getMap(String path, {String? bearer}) async {
    final uri = Uri.parse('$_root$path');
    final res = await http.get(uri, headers: _headers(bearer: bearer));
    return _decodeMap(res);
  }

  static Map<String, dynamic> _decodeMap(http.Response res) {
    dynamic j;
    try {
      j = jsonDecode(res.body);
    } catch (_) {
      if (res.statusCode >= 400) {
        throw ApiException(res.statusCode, res.body.isNotEmpty ? res.body : 'Request failed');
      }
      throw ApiException(res.statusCode, 'Invalid response');
    }
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, _errMsg(j));
    }
    if (j is! Map<String, dynamic>) throw ApiException(res.statusCode, 'Invalid response');
    return j;
  }

  static String _errMsg(dynamic j) {
    if (j is! Map) return 'Request failed';
    final e = j['error'];
    if (e is String) return e;
    if (e is Map) {
      final parsed = _parseValidationError(e);
      if (parsed != null) return parsed;
      try {
        return jsonEncode(e);
      } catch (_) {
        return e.toString();
      }
    }
    return 'Request failed';
  }

  /// Backend (zod) often returns:
  /// { error: { formErrors: [], fieldErrors: { email: ["Invalid email"] } } }
  /// Convert that shape into a user-friendly one-line message.
  static String? _parseValidationError(Map e) {
    final fieldErrors = e['fieldErrors'];
    if (fieldErrors is Map) {
      for (final entry in fieldErrors.entries) {
        final field = entry.key.toString();
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          final first = value.first?.toString().trim();
          if (first != null && first.isNotEmpty) return '$field: $first';
        } else if (value != null) {
          final msg = value.toString().trim();
          if (msg.isNotEmpty) return '$field: $msg';
        }
      }
    }

    final formErrors = e['formErrors'];
    if (formErrors is List && formErrors.isNotEmpty) {
      final first = formErrors.first?.toString().trim();
      if (first != null && first.isNotEmpty) return first;
    }

    // Support zod `format()` shape:
    // { _errors: [], email: { _errors: ["Invalid email"] } }
    final nested = _firstNestedError(e);
    if (nested != null) return nested;

    return null;
  }

  static String? _firstNestedError(dynamic value) {
    if (value is Map) {
      final errors = value['_errors'];
      if (errors is List) {
        for (final item in errors) {
          final msg = item?.toString().trim();
          if (msg != null && msg.isNotEmpty) return msg;
        }
      }
      for (final entry in value.entries) {
        final nested = _firstNestedError(entry.value);
        if (nested != null) return nested;
      }
      return null;
    }
    if (value is List) {
      for (final item in value) {
        final nested = _firstNestedError(item);
        if (nested != null) return nested;
      }
    }
    return null;
  }
}
