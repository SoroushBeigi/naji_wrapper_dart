import 'handlers/naji_handlers.dart';
import 'handlers/ipg_handlers.dart';
import 'package:shelf_router/shelf_router.dart';

class NajiRouter{
  static final NajiRouter _najiRouter = NajiRouter._internal();

  factory NajiRouter() {
    return _najiRouter;
  }

  final _router = Router()
  ..get('/getAllServices', getAllServices)
  ..post('/validateUser', validateUser)
  ..post('/sendOtp', sendOtp)
  ..post('/verifyOtp', verifyOtp)
  ..post('/drivingLicences', drivingLicences)
  ..post('/negativePoint', negativePoint)
  ..post('/licensePlates', licensePlates)
  ..post('/vehiclesViolations', vehiclesViolations)
  ..post('/violationsAggregate', violationsAggregate)
  ..post('/violationsImage', violationsImage)
  ..post('/vehiclesDocumentsStatus', vehiclesDocumentsStatus)
  ..get('/time', time);

  get router => _router;


  NajiRouter._internal();


}
