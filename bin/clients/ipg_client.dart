import 'package:dio/dio.dart';
import '../pretty_dio_logger.dart';

const baseUrl = 'https://ipgrest.asanpardakht.ir';

class IpgNetworkModule {
  static final IpgNetworkModule instance = IpgNetworkModule._internal();

  IpgNetworkModule._internal();

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
    dio.options.headers.addAll({
      'usr': 'trahi5105680',
      'pwd': 'Tra5246hi',
      'Content-Type': 'application/json',
      'Accept': '*/*',
    });
    dio.options.connectTimeout = const Duration(milliseconds: 60000);
    dio.options.receiveTimeout = const Duration(milliseconds: 60000);
    dio.options.sendTimeout = const Duration(milliseconds: 60000);
    return dio;
  }
}
