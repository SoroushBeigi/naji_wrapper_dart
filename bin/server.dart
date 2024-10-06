import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:dotenv/dotenv.dart';
import 'router.dart';

void main() async {
  final router = NajiRouter();
  final ip = InternetAddress.anyIPv4;

  final env = DotEnv(includePlatformEnvironment: true)..load();

  var connection = await Connection.open(Endpoint(
    host: env['DB_HOST'] ?? 'localhost',
    database: env['DB_NAME'] ?? 'db',
    username: env['DB_USER'] ?? 'postgres',
    password: env['DB_PASS'] ?? 'pass',
  ),settings: ConnectionSettings(sslMode: SslMode.disable));

  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(router.router.call);

  final port = int.parse(env['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
