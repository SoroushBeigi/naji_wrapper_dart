import 'package:http/http.dart' as http;
const baseUrl = 'http://172.16.251.76:7003/ords/cif';
class HttpClient{
  static final HttpClient _client = HttpClient._internal();
  factory HttpClient() {
    return _client;
  }

  HttpClient._internal();
}