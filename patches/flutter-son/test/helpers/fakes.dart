import 'dart:async';
import 'dart:convert';

import 'package:expense_tracker/core/constants/api_constants.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class FakeTokenStorage extends TokenStorage {
  String? _token;
  String? _userId;
  String? _email;
  String? _role;

  @override
  Future<void> init() async {}

  @override
  String? get token => _token;

  @override
  String? get userId => _userId;

  @override
  String? get email => _email;

  @override
  String? get role => _role;

  @override
  Future<void> saveSession({
    required String token,
    required String userId,
    String? email,
    String? role,
  }) async {
    _token = token;
    _userId = userId;
    _email = email;
    final trimmed = role?.trim();
    _role = (trimmed == null || trimmed.isEmpty) ? null : trimmed.toLowerCase();
  }

  @override
  Future<void> clear() async {
    _token = null;
    _userId = null;
    _email = null;
    _role = null;
  }
}

/// Records requests at the [http.Client] layer so [ApiClient._send]
/// (timeout + error mapping) is exercised in tests.
class FakeHttpClient extends http.BaseClient {
  final List<({String method, String path, Object? body})> requests = [];
  http.Response Function(String method, String path, Object? body)? handler;
  Object? throwOnNext;
  Duration? artificialDelay;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (artificialDelay != null) {
      await Future<void>.delayed(artificialDelay!);
    }

    final method = request.method.toUpperCase();
    final path = _apiRelativePath(request.url);
    Object? body;
    if (request is http.Request && request.body.isNotEmpty) {
      try {
        body = jsonDecode(request.body);
      } catch (_) {
        body = request.body;
      }
    }

    requests.add((method: method, path: path, body: body));

    if (throwOnNext != null) {
      final error = throwOnNext!;
      throwOnNext = null;
      throw error;
    }

    final response =
        handler?.call(method, path, body) ?? http.Response('', 200);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: {
        'content-type':
            response.headers['content-type'] ??
            'application/json; charset=utf-8',
        ...response.headers,
      },
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// ApiClient builds `{baseUrl}{path}` e.g. `…/api` + `/budgets?year=…`.
  static String _apiRelativePath(Uri url) {
    final full = url.path;
    final basePath = Uri.parse(ApiConstants.baseUrl).path; // e.g. /api
    String path;
    if (basePath.isNotEmpty && full.startsWith(basePath)) {
      final rest = full.substring(basePath.length);
      path = rest.isEmpty ? '/' : rest;
    } else {
      path = full;
    }
    if (url.hasQuery) return '$path?${url.query}';
    return path;
  }
}

/// [ApiClient] wired to [FakeHttpClient] — same surface tests already use.
class FakeApiClient extends ApiClient {
  FakeApiClient() : this._(FakeTokenStorage(), FakeHttpClient());

  FakeApiClient._(FakeTokenStorage storage, this.fakeHttp)
    : super(storage, client: fakeHttp);

  final FakeHttpClient fakeHttp;

  List<({String method, String path, Object? body})> get requests =>
      fakeHttp.requests;

  set handler(
    http.Response Function(String method, String path, Object? body)? value,
  ) => fakeHttp.handler = value;

  http.Response Function(String method, String path, Object? body)?
  get handler => fakeHttp.handler;

  set throwOnNext(Object? value) => fakeHttp.throwOnNext = value;

  Object? get throwOnNext => fakeHttp.throwOnNext;
}
