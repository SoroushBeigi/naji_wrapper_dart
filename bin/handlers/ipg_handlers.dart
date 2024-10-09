import 'package:shelf/shelf.dart';
import '../naji_response.dart';
import '../clients/ipg_client.dart';

Future<Response> time(Request request)async {
  final response = await IpgNetworkModule.instance.dio.get('/v1/Time');
  final najiResponse = NajiResponse(resultCode: 0, failures: [], data: response.data );
  return Response.ok(najiResponse.getJson(),
      headers: {"Content-Type": "application/json"});
}