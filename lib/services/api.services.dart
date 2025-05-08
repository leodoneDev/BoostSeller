// API Service : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:boostseller/utils/toast.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://boost-seller-web.netlify.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Response?> post(
    BuildContext context,
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      ToastUtil.error('Network error occured. Please check WiFi Connection.');

      rethrow;
    } catch (e) {
      ToastUtil.error('Some issues occurred. Please try again.');
      rethrow;
    }
  }
}
