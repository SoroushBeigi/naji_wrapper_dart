class UserModel {
  final String? id;
  final String? mobileNumber;
  final String? nationalCode;
  final String? guid;
  final String? firstName;
  final String? lastName;

  UserModel(
      {this.id,
      this.mobileNumber,
      this.nationalCode,
      this.guid,
      this.firstName,
      this.lastName});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      "nationalCode": nationalCode,
      'guid': guid,
      'firstName': firstName,
      'latName': lastName,
    };
  }
}
