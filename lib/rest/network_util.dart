import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:flutter/material.dart';

class NetworkUtil {
  // Singleton pattern
  static final NetworkUtil _instance = NetworkUtil._internal();

  factory NetworkUtil() {
    return _instance;
  }

  NetworkUtil._internal() {
    _dio = Dio(BaseOptions(baseUrl: BASE_URL));

    // Add interceptors once
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    final CacheConfig config = CacheConfig(
      baseUrl: BASE_URL,
      defaultMaxAge: const Duration(days: 7),
      databaseName: "FT",
    );
    _dio.interceptors.add(DioCacheManager(config).interceptor);
  }

  //static const String BASE_URL = "https://tutorbackend.herokuapp.com/api/v1/";
  static const String BASE_URL = "https://tvtorbackend.onrender.com/api/v1/";

  late final Dio _dio;

  Future<dynamic> post({
    Key? key,
    required String url,
    dynamic body,
    String? token,
    bool isFormData = false,
  }) async {
    final headers = <String, String>{
      if (!isFormData) ...{
        "Content-Type": "application/json",
        "Accept": "application/json",
      } else ...{
        "Content-Type": "multipart/form-data",
        "Accept": "application/json",
      },
      if (token != null) "Authorization": token,
    };

    final Options options = Options(headers: headers);

    try {
      final response = await _dio.post(
        Uri.encodeFull(url),
        data: body,
        options: options,
      );

      final int? statusCode = response.statusCode;

      if (statusCode == null || statusCode < 200 || statusCode > 400) {
        if (statusCode == 401) {
          throw Exception("401 Unauthorized");
        } else {
          throw Exception("Error while fetching data");
        }
      }

      // Make sure response.data is not null
      if (response.data == null) {
        throw Exception("Empty response data");
      }

      return response.data;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
      rethrow;
    }
  }

  Future<dynamic> deleteApi(String url, {String? token, dynamic body}) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": token,
    };

    final Options options = Options(headers: headers);

    try {
      final response = await _dio.delete(
        url,
        options: options,
        data: body,
      );

      final int? statusCode = response.statusCode;

      if (statusCode == null || statusCode < 200 || statusCode > 400) {
        if (statusCode == 401) {
          throw Exception("401 Unauthorized");
        } else {
          throw Exception("Error while fetching data");
        }
      }

      if (response.data == null) {
        throw Exception("Empty response data");
      }

      return response.data;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
      rethrow;
    }
  }

  Future<dynamic> get(
      String url, {
        String? token,
        Map<String, dynamic>? queryMap,
      }) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": token,
    };

    final Options options = buildCacheOptions(
      const Duration(days:7),
      options: Options(headers: headers),
      forceRefresh: true,
      primaryKey: "FT_Primary",
      subKey: "FT_Sub",
    );

    try {
      final response = await _dio.get(
        Uri.encodeFull(url),
        options: options,
        queryParameters: queryMap,
      );

      final int? statusCode = response.statusCode;

      if (statusCode == null || statusCode < 200 || statusCode > 400) {
        if (statusCode == 401) {
          throw Exception("401 Unauthorized");
        } else {
          throw Exception("Error while fetching data");
        }
      }

      if (response.data == null) {
        throw Exception("Empty response data");
      }
      return response.data;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
      rethrow;
    }
  }

  Future<dynamic> putApi(
      String url, {
        dynamic body,
        String? token,
        bool isFormData = false,
      }) async {
    final headers = <String, String>{
      if (!isFormData) ...{
        "Content-Type": "application/json",
        "Accept": "application/json",
      } else ...{
        "Content-Type": "multipart/form-data",
        "Accept": "application/json",
      },
      if (token != null) "Authorization": token,
    };

    final Options options = Options(headers: headers);

    try {
      final response = await _dio.put(
        url,
        data: body,
        options: options,
      );

      final int? statusCode = response.statusCode;

      if (statusCode == null || statusCode < 200 || statusCode > 500) {
        throw Exception("Error while fetching data");
      }

      if (response.data == null) {
        throw Exception("Empty response data");
      }

      return response.data;
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
      rethrow;
    }
  }
}
