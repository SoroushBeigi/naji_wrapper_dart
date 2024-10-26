import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'router.dart';
import 'db/service_repository.dart';
import 'db/invoice_repository.dart';
import 'constants.dart';
import 'package:shelf_static/shelf_static.dart';
import 'logger.dart';

void main() async {
  setupLogging();

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
      .addMiddleware(logRequestsAndResponses())
      .addHandler(Cascade().add(staticHandler).add(router.router.call).handler);

  final port = int.parse(Constants.port);
  final server = await serve(handler, ip, port);
  print("Server listening on ip ${ip.host} port ${server.port}");
}
