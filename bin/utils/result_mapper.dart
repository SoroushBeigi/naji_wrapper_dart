import '../constants.dart';

abstract class ResultMapper<T> {
  List<RowOfData> map(T model)=>[];
  List<List<RowOfData>> mapList(List<T> models)=>[];
}

final  url = '${Constants.baseUrl}:${Constants.port}';


class DrivingLicenseMapper extends ResultMapper<NajiDrivingLicensesModel> {
  @override
  List<List<RowOfData>> mapList(models) =>
      models.map((model) =>
      [
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
      ]
      ).toList();
}

class LicensePlateMapper extends ResultMapper<NajiLicensesPlateModel> {
  @override
  List<RowOfData> map(model) => [];
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
      );
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
