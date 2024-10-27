import '../constants.dart';
import 'date_converter.dart';

abstract class ResultMapper<T> {
  List<RowOfData> map(T model) => [];

  List<List<RowOfData>> mapList(List<T> models) => [];
}

final url = 'http://${Constants.baseUrl}:${Constants.port}';

class DrivingLicenseMapper extends ResultMapper<NajiDrivingLicensesModel> {
  @override
  List<List<RowOfData>> mapList(models) => models
      .map((model) => [
            RowOfData(
              title: 'نام',
              svg: '$url/svg/person.svg',
              description: model.firstName,
            ),
            RowOfData(
              title: 'نام خانوادگی',
              svg: '$url/svg/person.svg',
              description: model.lastName,
            ),
            RowOfData(
              title: 'نوع گواهینامه',
              svg: '$url/svg/description.svg',
              description: model.title,
            ),
            RowOfData(
              title: 'شماره گواهینامه',
              svg: '$url/svg/confirmation_number.svg',
              description: model.printNumber,
            ),
            RowOfData(
              title: 'بارکد گواهینامه',
              svg: '$url/svg/barcode.svg',
              description: model.barcode,
            ),
            RowOfData(
              title: 'وضعیت گواهینامه',
              svg: '$url/svg/done.svg',
              description: model.rahvarStatus,
            ),
            RowOfData(
              title: 'تاریخ صدور گواهینامه',
              svg: '$url/svg/calendar_month.svg',
              description: model.printDate,
            ),
            RowOfData(
              title: 'مدت اعتبار گواهینامه',
              svg: '$url/svg/calendar_month.svg',
              description: model.validYears,
            ),
          ])
      .toList();
}

class LicensePlatesMapper extends ResultMapper<NajiLicensesPlateModel> {
  @override
  List<List<RowOfData>> mapList(models) => models.map((model) {
        final List<dynamic>? jalaliDate;
        if (model.separationDate == null) {
          jalaliDate = null;
        } else {
          String dateString = model.separationDate!.split(' ')[0];
          int year = int.parse(dateString.substring(0, 4));
          int month = int.parse(dateString.substring(5, 7));
          int day = int.parse(dateString.substring(8, 10));
          jalaliDate = gregorianToJalali(year, month, day);
        }

        return [
          RowOfData(
            title: 'سریال',
            svg: '$url/svg/confirmation_number.svg',
            description: model.serial,
          ),
          RowOfData(
            title: 'توضیحات',
            svg: '$url/svg/description.svg',
            description: model.description,
          ),
          RowOfData(
            title: 'شماره پلاک',
            svg: '$url/svg/directions_car.svg',
            description: model.licensePlate,
          ),
          RowOfData(
              title: 'تاریخ فک پلاک',
              svg: '$url/svg/calendar_month.svg',
              description: jalaliDate == null
                  ? null
                  : '${jalaliDate[0]}/${jalaliDate[1]}/${jalaliDate[2]} ${model.separationDate!.split(' ')[1]}')
        ];
      }).toList();
}

class VehicleViolationsMapper extends ResultMapper<ViolationModel> {
  @override
  List<List<RowOfData>> mapList(models) => models.map((model) {
        return [
          RowOfData(
              title: 'تاریخ وقوع تخلف',
              svg: '$url/svg/calendar_month.svg',
              description: model.violationOccuredDate),
          RowOfData(
              title: 'نوع تخلف',
              svg: '$url/svg/traffic.svg',
              description: model.violationType?.violationTypeName),
          RowOfData(
              title: 'نوع ثبت تخلف',
              svg: '$url/svg/speed_camera.svg',
              description: model.violationOccuredDate),
          RowOfData(
              title: 'محل وقوع تخلف',
              svg: '$url/svg/location.svg',
              description: model.violationAddress),
          RowOfData(
              title: 'نوع ثبت تخلف',
              svg: '$url/svg/speed_camera.svg',
              description: model.violationOccuredDate),
          RowOfData(
              title: 'آیا برای این تخلف تصویر وجود دارد',
              svg: '$url/svg/image.svg',
              description: (model.hasImage ?? false) ? 'بله' : 'خیر'),
        ];
      }).toList();
}

class NegativePointMapper extends ResultMapper<NajiNegativePointModel> {
  @override
  List<RowOfData> map(model) => [
        RowOfData(
          title: 'نمره منفی',
          svg: '$url/svg/do_not_disturb_on.svg',
          description: model.negativePoint,
        ),
        RowOfData(
          title: 'آیا اجازه رانندگی دارد',
          svg: '$url/svg/pan_tool.svg',
          description: model.isDrivingAllowed == null
              ? '-'
              : model.isDrivingAllowed == "true"
                  ? 'بله'
                  : 'خیر',
        ),
      ];
}

class ViolationsAggregateMapper
    extends ResultMapper<NajiVehiclesViolationsAggregateModel> {
  @override
  List<RowOfData> map(model) => [
        RowOfData(
          title: 'مبلغ حریمه',
          svg: '$url/svg/payments.svg',
          description: model.price ?? '-',
        ),
        RowOfData(
            title: 'وضعیت شکایت',
            svg: '$url/svg/pan_tool.svg',
            description: model.complaintStatus ?? 'شکایت ندارد'),
        RowOfData(
            title: 'پلاک',
            svg: '$url/svg/directions_car.svg',
            description: model.plateChar ?? '-'),
      ];
}

class VehicleDocumentStatusMapper
    extends ResultMapper<NajiVehiclesDocumentsStatusModel> {
  @override
  List<RowOfData> map(model) => [
        RowOfData(
          title: 'تاریخ صدور کارت',
          svg: '$url/svg/calendar_month.svg',
          description: model.cardPrintDate ?? '-',
        ),
        RowOfData(
            title: 'وضعیت ارسال کارت خودرو',
            svg: '$url/svg/done.svg',
            description: model.cardStatusTitle ?? '-'),
        RowOfData(
            title: 'بارکد پستی کارت خودرو',
            svg: '$url/svg/barcode.svg',
            description: model.cardPostalBarcode ?? '-'),
        RowOfData(
            title: 'تاریخ چاپ سند',
            svg: '$url/svg/calendar_month.svg',
            description: model.documentPrintDate ?? '-'),
        RowOfData(
            title: 'وضعیت صدور سند',
            svg: '$url/svg/done.svg',
            description: model.documentStatusTitle ?? '-'),
        RowOfData(
            title: 'بارکد پستی سند',
            svg: '$url/svg/barcode.svg',
            description: model.documentPostalBarcode ?? '-'),
        RowOfData(
            title: 'پلاک',
            svg: '$url/svg/directions_car.svg',
            description: model.plateChar ?? '-'),
      ];
}

class VehicleConditionsMapper extends ResultMapper<NajiVehicleConditionsModel> {
  @override
  List<RowOfData> map(model) => [
        RowOfData(
          title: 'تیپ خودرو',
          svg: '$url/svg/garage.svg',
          description: model.tip ?? '-',
        ),
        RowOfData(
            title: 'مبلغ خلافی خودرو تا این لحظه',
            svg: '$url/svg/payments.svg',
            description: model.violationPrice ?? '-'),
        RowOfData(
            title: 'وضعیت قابل معامله بودن خودرو',
            svg: '$url/svg/no_crash.svg',
            description: model.transactionStatus ?? '-'),
        RowOfData(
            title: 'مدل خودرو',
            svg: '$url/svg/directions_car.svg',
            description: model.model ?? '-'),
        RowOfData(
            title: 'نوع سوخت',
            svg: '$url/svg/local_gas_station.svg',
            description: model.fuel ?? '-'),
        RowOfData(
            title: 'نوع کاربری',
            svg: '$url/svg/directions_car.svg',
            description: model.usage ?? '-'),
        RowOfData(
            title: 'زیر نوع کاربری',
            svg: '$url/svg/directions_car.svg',
            description: model.subUsage ?? '-'),
        RowOfData(
            title: 'تاریخ شروع بیمه',
            svg: '$url/svg/calendar_month.svg',
            description: model.insuranceStartDate ?? '-'),
        RowOfData(
            title: 'تاریخ اتمام بیمه',
            svg: '$url/svg/calendar_month.svg',
            description: model.insuranceEndDate ?? '-'),
        RowOfData(
            title: 'کد پیگیری جهت استعلام',
            svg: '$url/svg/confirmation_number.svg',
            description: model.trackingCode ?? '-'),
        RowOfData(
            title: 'تعداد دفعات تعویض پلاک خودرو',
            svg: '$url/svg/directions_car.svg',
            description: model.carTransactionCount ?? '-'),
        RowOfData(
            title: 'مبلغ عوارض آزاد راهی بر حسب ریال ',
            svg: '$url/svg/road.svg',
            description: model.freeWayTollsPrice ?? '-'),
        RowOfData(
            title: ' مبلغ مالیات نقل و انتقال',
            svg: '$url/svg/payments.svg',
            description: model.taxPrice ?? '-'),
        RowOfData(
            title: 'رنگ خودرو',
            svg: '$url/svg/palette.svg',
            description: model.color ?? '-'),
        RowOfData(
            title: ' سیستم خودرو',
            svg: '$url/svg/garage.svg',
            description: model.system ?? '-'),
        RowOfData(
            title: ' لیست خسارت های پرداختی از بیمه',
            svg: '$url/svg/payments.svg',
            description: model.insurance ?? '-'),
      ];
}

class RowOfData {
  final String? title;
  final String? svg;
  final String? description;

  RowOfData(
      {required this.title, required this.svg, required this.description});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'svg': svg,
    };
  }
}

class NajiDrivingLicensesModel {
  final String? nationalCode;
  final String? firstName;
  final String? lastName;
  final String? title;
  final String? rahvarStatus;
  final String? barcode;
  final String? printNumber;
  final String? printDate;
  final String? validYears;

  NajiDrivingLicensesModel(
      {this.nationalCode,
      this.firstName,
      this.lastName,
      this.title,
      this.rahvarStatus,
      this.barcode,
      this.printNumber,
      this.printDate,
      this.validYears});

  factory NajiDrivingLicensesModel.fromJson(Map<String, dynamic> json) =>
      NajiDrivingLicensesModel(
        nationalCode: json["nationalCode"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        title: json["title"],
        rahvarStatus: json["rahvarStatus"],
        barcode: json["barcode"],
        printNumber: json["printNumber"],
        printDate: json["printDate"],
        validYears: json["validYears"],
      );
}

class NajiLicensesPlateModel {
  final String? serial;
  final String? licensePlateNumber;
  final String? description;
  final String? separationDate;
  final String? licensePlate;

  NajiLicensesPlateModel(
      {this.serial,
      this.licensePlateNumber,
      this.description,
      this.separationDate,
      this.licensePlate});

  factory NajiLicensesPlateModel.fromJson(Map<String, dynamic> json) =>
      NajiLicensesPlateModel(
        licensePlateNumber: json["licensePlateNumber"],
        description: json["description"],
        separationDate: json["separationDate"],
        licensePlate: json["licensePlate"],
        serial: json["serial"],
      );
}

class NajiNegativePointModel {
  final String? negativePoint;
  final String? isDrivingAllowed;
  final String? resultStatusMessage;
  final int? resultStatus;

  NajiNegativePointModel({
    this.negativePoint,
    this.isDrivingAllowed,
    this.resultStatus,
    this.resultStatusMessage,
  });

  factory NajiNegativePointModel.fromJson(Map<String, dynamic> json) =>
      NajiNegativePointModel(
        negativePoint: json["negativePoint"],
        isDrivingAllowed: json["isDrivingAllowed"],
        resultStatus: json["resultStatus"],
        resultStatusMessage: json["resultStatusMessage"],
      );
}

class NajiVehiclesDocumentsStatusModel {
  final String? cardPrintDate;
  final String? cardPostalBarcode;
  final String? cardStatusTitle;
  final String? documentPrintDate;
  final String? documentStatusTitle;
  final String? documentPostalBarcode;
  final String? plateChar;
  final int? resultStatus;
  final String? resultStatusMessage;

  NajiVehiclesDocumentsStatusModel(
      {this.cardPrintDate,
      this.cardPostalBarcode,
      this.documentStatusTitle,
      this.documentPrintDate,
      this.cardStatusTitle,
      this.plateChar,
      this.documentPostalBarcode,
      this.resultStatus,
      this.resultStatusMessage});

  factory NajiVehiclesDocumentsStatusModel.fromJson(
          Map<String, dynamic> json) =>
      NajiVehiclesDocumentsStatusModel(
          plateChar: json["plateChar"],
          cardPrintDate: json["cardPrintDate"],
          cardPostalBarcode: json["cardPostalBarcode"],
          cardStatusTitle: json["cardStatusTitle"],
          documentPrintDate: json["documentPrintDate"],
          documentStatusTitle: json["documentStatusTitle"],
          resultStatus: json["resultStatus"],
          resultStatusMessage: json["resultStatusMessage"],
          documentPostalBarcode: json['documentPostalBarcode']);
}

class NajiVehicleConditionsModel {
  final String? carTransactionCount;
  final String? color;
  final String? freeWayTollsPrice;
  final String? fuel;
  final String? insuranceEndDate;
  final String? insuranceStartDate;
  final String? subUsage;
  final String? system;
  final String? taxPrice;
  final String? tip;
  final String? trackingCode;
  final String? transactionStatus;
  final String? usage;
  final String? violationPrice;
  final String? model;
  final String? insurance;

  factory NajiVehicleConditionsModel.fromJson(Map<String, dynamic> json) =>
      NajiVehicleConditionsModel(
        carTransactionCount: json['carTransactionCount'],
        color: json['color'],
        freeWayTollsPrice: json['freeWayTollsPrice'],
        fuel: json['fuel'],
        insuranceEndDate: json['insuranceEndDate'],
        insuranceStartDate: json['insuranceStartDate'],
        subUsage: json['subUsage'],
        system: json['system'],
        taxPrice: json['taxPrice'],
        tip: json['tip'],
        trackingCode: json['trackingCode'],
        transactionStatus: json['transactionStatus'],
        usage: json['usage'],
        violationPrice: json['violationPrice'],
        model: json['model'],
        insurance: json['insurance'],
      );

  NajiVehicleConditionsModel({
    this.insurance,
    this.model,
    this.carTransactionCount,
    this.color,
    this.freeWayTollsPrice,
    this.fuel,
    this.insuranceEndDate,
    this.insuranceStartDate,
    this.subUsage,
    this.system,
    this.taxPrice,
    this.tip,
    this.trackingCode,
    this.transactionStatus,
    this.usage,
    this.violationPrice,
  });
}

class NajiVehiclesViolationsAggregateModel {
  final String? plateChar;
  final String? priceStatus;
  final int? resultStatus;
  final String? resultStatusMessage;
  final String? paperId;
  final String? paymentId;
  final String? price;
  final String? complaintStatus;

  NajiVehiclesViolationsAggregateModel({
    this.plateChar,
    this.priceStatus,
    this.resultStatus,
    this.paperId,
    this.paymentId,
    this.price,
    this.resultStatusMessage,
    this.complaintStatus,
  });

  factory NajiVehiclesViolationsAggregateModel.fromJson(
          Map<String, dynamic> json) =>
      NajiVehiclesViolationsAggregateModel(
        plateChar: json["plateChar"],
        priceStatus: json["priceStatus"],
        paperId: json["paperId"],
        paymentId: json["paymentId"],
        price: json["price"],
        resultStatus: json["resultStatus"],
        resultStatusMessage: json["resultStatusMessage"],
        complaintStatus: json["complaintStatus"],
      );
}

class ViolationModel {
  String? violationId;
  String? violationOccuredDate;
  String? violationOccuredTime;
  ViolationDeliveryTypeModel? violationDeliveryType;
  String? violationAddress;
  ViolationTypeModel? violationType;
  String? finalPrice;
  String? paperId;
  String? paymentId;
  bool? hasImage;

  ViolationModel({
    this.violationId,
    this.violationOccuredDate,
    this.violationOccuredTime,
    this.violationDeliveryType,
    this.violationAddress,
    this.violationType,
    this.finalPrice,
    this.paperId,
    this.paymentId,
    this.hasImage,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) {
    return ViolationModel(
      violationId: json['violationId'],
      violationOccuredDate: json['violationOccuredDate'],
      violationOccuredTime: json['violationOccuredTime'],
      violationDeliveryType:
          ViolationDeliveryTypeModel.fromJson(json['violationDeliveryType']),
      violationAddress: json['violationAddress'],
      violationType: ViolationTypeModel.fromJson(json['violationType']),
      finalPrice: json['finalPrice'],
      paperId: json['paperId'],
      paymentId: json['paymentId'],
      hasImage: json['hasImage'],
    );
  }
}

class NajiVehiclesViolationsModel {
  List<ViolationModel?>? violations;
  String? plateDictation;
  String? plateChar;
  String? updateViolationsDate;
  String? inquiryDate;
  String? inquiryTime;
  String? priceStatus;
  String? inquirePrice;
  String? paperId;
  String? paymentId;

  NajiVehiclesViolationsModel({
    this.violations,
    this.plateDictation,
    this.plateChar,
    this.updateViolationsDate,
    this.inquiryDate,
    this.inquiryTime,
    this.priceStatus,
    this.inquirePrice,
    this.paperId,
    this.paymentId,
  });

  factory NajiVehiclesViolationsModel.fromJson(Map<String, dynamic> json) {
    return NajiVehiclesViolationsModel(
      violations: json['violations'] != null
          ? (json['violations'] as List<dynamic>)
              .map((violation) => ViolationModel.fromJson(violation))
              .toList()
          : [],
      plateDictation: json["plateDictation"],
      plateChar: json["plateChar"],
      updateViolationsDate: json["updateViolationsDate"],
      inquiryDate: json["inquiryDate"],
      inquiryTime: json["inquiryTime"],
      priceStatus: json["priceStatus"],
      inquirePrice: json["inquirePrice"],
      paperId: json["paperId"],
      paymentId: json["paymentId"],
    );
  }
}

class ViolationDeliveryTypeModel {
  String? violationDeliveryTypeName;

  ViolationDeliveryTypeModel({this.violationDeliveryTypeName});

  factory ViolationDeliveryTypeModel.fromJson(Map<String, dynamic> json) {
    return ViolationDeliveryTypeModel(
      violationDeliveryTypeName: json['violationDeliveryTypeName'],
    );
  }
}

class ViolationTypeModel {
  String? violationTypeId;
  String? violationTypeName;

  ViolationTypeModel({this.violationTypeId, this.violationTypeName});

  factory ViolationTypeModel.fromJson(Map<String, dynamic> json) {
    return ViolationTypeModel(
      violationTypeId: json['violationTypeId'],
      violationTypeName: json['violationTypeName'],
    );
  }
}
