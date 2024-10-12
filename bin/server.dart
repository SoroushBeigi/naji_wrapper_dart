import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'router.dart';
import 'db/service_repository.dart';
import 'db/invoice_repository.dart';

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
    host: "172.16.4.146" ,
    database: 'naji_db' ,
    username: 'wrapper',
    password: 'bpj12345',
  ),settings: ConnectionSettings(sslMode: SslMode.disable));

  ServiceRepository(connection).init();
  InvoiceRepository(connection).init();


  final serviceRepository = ServiceRepository(connection);
  final list = await serviceRepository.getAll();

  //EXAMPLE: database repository usage
  print(list[0].id);
  print(list[0].serviceName);
  print(list[0].price);
  print(list[0].inputs);
  print(list[0].title);

  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(router.router.call);

  final port = int.parse('9876');
  final server = await serve(handler, ip, port);
  print('Server listening on ip $ip port ${server.port}');
}
