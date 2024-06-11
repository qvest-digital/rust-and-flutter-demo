import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/environment.dart';

mixin Client {
  static final _env = getEnv();

  static String get _baseUrl {
    if (_env == Environment.prod) {
      return 'TODO:tbd';
    }
    try {
      return Platform.isAndroid
          ? 'http://10.0.2.2:8090'
          : 'http://127.0.0.1:8090';
    } catch (_) {
      return 'http://127.0.0.1:8090';
    }
  }

  static Dio get() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      contentType: ContentType.json.mimeType,
    ));

    if (_env == Environment.local) {
      dio.interceptors.add(LogInterceptor());
    }

    return dio;
  }
}
