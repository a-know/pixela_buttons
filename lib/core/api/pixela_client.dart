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

    handler.next(err);
  }

  Future<Response<dynamic>> _requestWithRetry(
      Future<Response<dynamic>> Function() request) async {
    const maxRetries = 30;
    for (var i = 0; i <= maxRetries; i++) {
      try {
        return await request();
      } on DioException catch (e) {
        if (i < maxRetries &&
            e.response?.statusCode == 503 &&
            e.response?.data is Map &&
            (e.response?.data as Map)['isRejected'] == true) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        rethrow;
      }
    }
    throw StateError('unreachable');
  }

  Future<void> createGraph({
    required String username,
    required String id,
    required String name,
    required String unit,
    required String type,
    required String color,
    String? timezone,
  }) async {
    await _dio.post(
      ApiEndpoints.graphs(username),
      data: {
        'id': id,
        'name': name,
        'unit': unit,
        'type': type,
        'color': color,
        'timezone': timezone,
      },
    );
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
    await _requestWithRetry(() => _dio.put(
          ApiEndpoints.add(username, graphId),
          data: {'quantity': _quantityString(value)},
        ));
  }

  Future<void> subtractPixel(
      String username, String graphId, double value) async {
    await _requestWithRetry(() => _dio.put(
          ApiEndpoints.subtract(username, graphId),
          data: {'quantity': _quantityString(value)},
        ));
  }

  String _quantityString(double value) =>
      value == value.truncateToDouble() ? value.toInt().toString() : value.toString();

  Future<String> getGraphSvg(String username, String graphId, {bool darkMode = false}) async {
    final response = await _dio.get(
      '${ApiEndpoints.graphs(username)}/$graphId',
      queryParameters: {
        'transparent': 'true',
        if (darkMode) 'mode': 'dark',
        'nocache': DateTime.now().microsecondsSinceEpoch,
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          'Cache-Control': 'no-cache, no-store',
          'Pragma': 'no-cache',
        },
      ),
    );
    return response.data as String;
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
