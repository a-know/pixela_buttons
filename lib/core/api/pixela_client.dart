import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

typedef OnUnauthorized = void Function();

class PixelaClient {
  late final Dio _dio;
  OnUnauthorized? onUnauthorized;

  PixelaClient() {
    _dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _attachToken,
      onError: _handleError,
    ));
  }

  Future<void> _attachToken(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['X-USER-TOKEN'] = token;
    }
    handler.next(options);
  }

  Future<void> _handleError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorage.deleteToken();
      onUnauthorized?.call();
      handler.reject(err);
      return;
    }

    // 503 + isRejected: true → retry indefinitely with 500ms interval
    if (err.response?.statusCode == 503) {
      final data = err.response?.data;
      if (data is Map && data['isRejected'] == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // falls through to retry again on next error intercept
        }
      }
    }

    handler.next(err);
  }

  Future<List<Map<String, dynamic>>> getGraphs(String username) async {
    final response = await _dio.get(ApiEndpoints.graphs(username));
    final graphs = response.data['graphs'] as List<dynamic>;
    return graphs.cast<Map<String, dynamic>>();
  }

  Future<void> createUser({
    required String username,
    required String token,
    required bool agreeTermsOfService,
    required bool notMinor,
  }) async {
    await _dio.post(
      ApiEndpoints.createUser(),
      data: {
        'token': token,
        'username': username,
        'agreeTermsOfService': agreeTermsOfService ? 'yes' : 'no',
        'notMinor': notMinor ? 'yes' : 'no',
      },
      options: Options(headers: {'X-USER-TOKEN': token}),
    );
  }

  Future<void> addPixel(
      String username, String graphId, double value) async {
    await _dio.post(
      ApiEndpoints.add(username, graphId),
      data: {'quantity': value.toString()},
    );
  }

  Future<void> subtractPixel(
      String username, String graphId, double value) async {
    await _dio.post(
      ApiEndpoints.subtract(username, graphId),
      data: {'quantity': value.toString()},
    );
  }

  Future<double?> getTodayValue(String username, String graphId) async {
    final response = await _dio.get(
      ApiEndpoints.pixelToday(username, graphId),
    );
    final quantity = response.data['quantity'];
    return double.tryParse(quantity.toString());
  }
}

// Singleton instance
final pixelaClient = PixelaClient();
