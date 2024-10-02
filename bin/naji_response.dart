import 'dart:convert';

class NajiResponse{
  final int resultCode;
  final dynamic data;
  final List<String>? failures;

  NajiResponse({required this.resultCode,this.data, this.failures});

  String getJson(){
    final Map<String,dynamic> response = {"resultCode":resultCode,"failures":failures,"data":data};
    return jsonEncode(response);
  }


}