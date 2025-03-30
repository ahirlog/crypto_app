import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/exceptions.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = ApiConstants.headers;
    _dio.options.connectTimeout = const Duration(milliseconds: 15000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 15000);
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.statusMessage ?? 'Server Error',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
