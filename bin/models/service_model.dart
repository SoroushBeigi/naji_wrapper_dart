class ServiceModel {
  final String? id;
  final String? price;
  final String? serviceName;
  final String? title;
  final String? inputs;

  ServiceModel({
    this.id,
    this.price,
    this.serviceName,
    this.title,
    this.inputs,
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
