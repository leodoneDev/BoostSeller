// API Service : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  late final Dio _dio;
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.realBackendURL,
        // baseUrl: Config.testBackendURL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<Response?> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message} - ${e.response?.data}");
      ToastUtil.error('Network error occured.\nPlease check WiFi Connection.');
      rethrow;
    } catch (e) {
      ToastUtil.error('Some issues occurred.\nPlease try again.');
      rethrow;
    }
  }

  Future<Response?> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message} - ${e.response?.data}");
      ToastUtil.error('Network error occurred.\nPlease check WiFi Connection.');
      rethrow;
    } catch (e) {
      ToastUtil.error('Some issues occurred.\nPlease try again.');
      rethrow;
    }
  }
}
