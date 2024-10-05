import 'package:dio/dio.dart';
import 'pretty_dio_logger.dart';

const baseUrl = 'http://172.16.251.76:7003/ords/cif';

class NetworkModule {
  static final NetworkModule _instance = NetworkModule._internal();

  NetworkModule._internal();

  factory NetworkModule() {
    return _instance;
  }

  Dio get dio => _getDio();

  PrettyDioLogger get prettyDioLogger => PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
      error: true,
      compact: true,
      maxWidth: 120);

  _getDio() {
    var dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(prettyDioLogger);
    dio.options.connectTimeout = const Duration(milliseconds: 60000);
    dio.options.receiveTimeout = const Duration(milliseconds: 60000);
    dio.options.sendTimeout = const Duration(milliseconds: 60000);
    return dio;
  }
}
