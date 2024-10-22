import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'constants.dart';

final Logger logger = Logger('ShelfLogger');

void setupLogging() {
  hierarchicalLoggingEnabled = true;
  logger.level = Level.INFO;

  final logFile = File('../../logs/logfile.log');
  logFile.createSync(recursive: true);
  IOSink logSink = logFile.openWrite(mode: FileMode.append);

  logger.onRecord.listen((record) {
    final logEntry = {
      'level': record.level.name,
      'message': record.message,
      'time': record.time.toIso8601String(),
    };
    logSink.write('$logEntry\n');
    if(!Constants.isProduction){
      print(logEntry);
    }
  });
}

Middleware logRequestsAndResponses() {
  return (Handler innerHandler) {
    return (Request request) async {
      final requestBody = await request.readAsString();

      final requestLog = {
        'type': 'request',
        'method': request.method,
        'url': request.requestedUri.toString(),
        'headers': request.headers,
        'body': requestBody,
        'time': DateTime.now().toIso8601String(),
      };

      logger.info(requestLog); // Log the request map directly

      final newRequest = request.change(body: requestBody);

      final response = await innerHandler(newRequest);

      final responseBody = await response.readAsString();

      final responseLog = {
        'type': 'response',
        'status': response.statusCode,
        'headers': response.headers,
        'body': responseBody,
        'time': DateTime.now().toIso8601String(),
      };

      logger.info(responseLog); // Log the response map directly

      return response.change(body: responseBody);
    };
  };
}
