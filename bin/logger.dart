import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'constants.dart';

final Logger logger = Logger('ShelfLogger');

void setupLogging() {
  final logstashLogger = LogstashLogger('localhost', 5044);
  hierarchicalLoggingEnabled = true;
  logger.level = Level.INFO;

  logger.onRecord.listen((record) {
    final decodedMessage = jsonDecode(record.message);
    final logEntry = {
      'level': record.level.name,
      'time': record.time.toIso8601String(),
      'type': decodedMessage?['type'] ?? '',
      'headers': decodedMessage['headers'],
      'body': decodedMessage['body'],
    };
    if (decodedMessage?['type'] == 'Request') {
      logEntry.addAll({
        'url': decodedMessage['url'],
        'method': decodedMessage['method'],
      });
    }
    if (decodedMessage?['type'] == 'Response') {
      logEntry.addAll({
        'status': decodedMessage['status'],
      });
    }
    logstashLogger.log(logEntry);

    if (!Constants.isProduction) {
      print(logEntry);
    }
  });
}

Middleware logRequestsAndResponses() {
  return (Handler innerHandler) {
    return (Request request) async {
      final requestBody = await request.readAsString();

      final requestLog = {
        'type': 'Request',
        'method': request.method,
        'url': request.requestedUri.toString(),
        'headers': request.headers,
        'body': requestBody,
        'time': DateTime.now().toIso8601String(),
      };

      logger.info(jsonEncode(requestLog));

      final newRequest = request.change(body: requestBody);
      final response = await innerHandler(newRequest);

      final responseBody = await response.readAsString();

      final responseLog = {
        'type': 'Response',
        'status': response.statusCode,
        'headers': response.headers,
        'body': responseBody,
        'time': DateTime.now().toIso8601String(),
      };

      logger.info(jsonEncode(responseLog));

      return response.change(body: responseBody);
    };
  };
}

class LogstashLogger {
  static final LogstashLogger instance = LogstashLogger._internal();
  late final String host;
  late final int port;
  Socket? _socket;

  LogstashLogger._internal();

  factory LogstashLogger(String host, int port) {
    instance.host = host;
    instance.port = port;
    instance._connect();
    return instance;
  }

  void _connect() async {
    try {
      _socket = await Socket.connect(host, port);
    } catch (e) {
      print('Error connecting to Logstash: $e');
    }
  }

  void log(Map<String, dynamic> logEntry) {
    if (_socket != null) {
      final logMessage = jsonEncode(logEntry);
      _socket!.write('$logMessage\n');
    } else {
      print('Logstash connection not established. Log message: $logEntry');
    }
  }

  void close() {
    _socket?.close();
  }
}
