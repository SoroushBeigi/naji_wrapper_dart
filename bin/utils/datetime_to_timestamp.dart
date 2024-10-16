//Used to map Dart's DateTime to Postgres' TIMESTAMP
String dateTimeToTimestamp(DateTime dateTime){
  String timestamp = dateTime.toIso8601String().replaceAll('T', ' ').split('.')[0];
  return timestamp;
}