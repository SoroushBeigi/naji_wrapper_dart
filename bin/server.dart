import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'router.dart';
import 'db/service_repository.dart';
import 'db/invoice_repository.dart';
import 'constants.dart';
import 'package:shelf_static/shelf_static.dart';

// const PORT='8080';
// const DB_PORT='5432';
// const DB_HOST='host.docker.internal';
// const DB_USER='postgres';
// const DB_PASS='123456';
// const DB_NAME='test_db';

void main() async {
  // var environment = Platform.environment['ENVIRONMENT'] ?? 'local';
  //
  // environment = environment.trim().toLowerCase();
  //
  // if (environment == 'local') {
  //   load();
  // }
  //DOCKER COMPOSE:
  // final DB_HOST = env['DB_HOST'] ?? 'db';
  // final DB_PORT = int.parse(env['DB_PORT']??'5432');
  // final DB_USER = env['DB_USER'] ?? 'wrapper';
  // final DB_PASS = env['DB_PASS'] ?? 'bpj12345';
  // final DB_NAME = env['DB_NAME'] ?? 'naji_db';

  //TEST:
  // final DB_HOST ='localhost';
  // final DB_PORT = 5432;
  // final DB_USER = 'postgres';
  // final DB_PASS = '123456';
  // final DB_NAME = 'naji_db';

  final router = NajiRouter();
  final ip = InternetAddress.anyIPv4;


  var connection = await Connection.open(Endpoint(
    port: 5432,
    host: Constants.dbHost ,
    database: 'naji_db' ,
    username: 'wrapper',
    password: 'bpj12345',
  ),settings: ConnectionSettings(sslMode: SslMode.disable));

  ServiceRepository(connection).init();
  InvoiceRepository(connection).init();

  final staticHandler = createStaticHandler('../assets', defaultDocument: null);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(Cascade().add(staticHandler).add(router.router.call).handler);

  final port = int.parse(Constants.port);
  final server = await serve(handler, ip, port);
  print('Server listening on ip $ip port ${server.port}');
}
