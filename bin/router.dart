import 'handlers/naji_handlers.dart';
import 'handlers/ipg_handlers.dart';
import 'handlers/service_handlers.dart';
import 'package:shelf_router/shelf_router.dart';

class NajiRouter {
  static final NajiRouter _najiRouter = NajiRouter._internal();

  factory NajiRouter() {
    return _najiRouter;
  }

  final _router = Router()
    ..get('/service/<id>', getService)
    ..get('/getAllServices', getAllServices)
    ..post('/service', addService)
    ..put('/service', updateService)
    ..delete('/service', deleteService)
    ..post('/validateUser', validateUser)
    ..post('/sendOtp', sendOtp)
    ..post('/verifyOtp', verifyOtp)
    // ..post('/drivingLicences', drivingLicences)
    // ..post('/negativePoint', negativePoint)
    // ..post('/licensePlates', licensePlates)
    // ..post('/vehiclesViolations', vehiclesViolations)
    // ..post('/violationsAggregate', violationsAggregate)
    ..post('/violationsImage', violationsImage)
    // ..post('/vehiclesDocumentsStatus', vehiclesDocumentsStatus)
    ..get('/time', time)
    ..post('/payment', payment)
    ..get('/paymentGateway', paymentGateway)
    ..get('/callback', callback)
    ..post('/callback', callback)
    ..post('/serviceResult', serviceResult)
    ..post('/serviceHistory',serviceHistory);

  get router => _router;

  NajiRouter._internal();
}
