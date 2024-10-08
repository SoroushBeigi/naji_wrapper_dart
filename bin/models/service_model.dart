class ServiceModel {
  final String id;
  final String price;
  final String serviceName;
  final String title;
  final String inputs;

  ServiceModel({
    required this.id,
    required this.price,
    required this.serviceName,
    required this.title,
    required this.inputs,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      "price": price,
      'inputs': inputs,
      'title': title,
    };
  }
}
