// API Service : made by Leo on 2025/05/04

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.227:3000', // Replace with your base URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Response?> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      print('🚨 Unknown Error: $e');
      rethrow;
    }
  }
}
