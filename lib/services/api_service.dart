import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options.baseUrl = 'https://dummyjson.com';
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response?.data['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response?.data['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      await _dio.delete(endpoint);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response?.data['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response?.data['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }
}
