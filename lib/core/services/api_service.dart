import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Add logging interceptor for debugging
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    logPrint: (object) => print(object),
  ));

  if (!kIsWeb) {
    // Mobile: Use httpOnly cookies
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }

  // Add auth interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print('Request: ${options.method} ${options.path}');
        print('Headers: ${options.headers}');
        handler.next(options);
      },
      onError: (error, handler) async {
        print('Dio Error: ${error.type}');
        print('Error Message: ${error.message}');
        print('Error Response: ${error.response?.data}');

        // Handle 401 errors by clearing auth data
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('jwt');
          await prefs.remove('currentUser');
          print('Unauthorized - cleared auth data');
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});