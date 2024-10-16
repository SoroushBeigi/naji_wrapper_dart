//Used to map Dart's DateTime to Postgres' TIMESTAMP
String dateTimeToTimestamp(DateTime dateTime){
  String timestamp = dateTime.toIso8601String().replaceAll('T', ' ').split('.')[0];
  return timestamp;
}

//Used to map ipg's localDate to Postgres' TIMESTAMP
String localDateToTimestamp(String localDate){
  String datePart = localDate.substring(0, 8);
  String timePart = localDate.substring(9, 15);

  int year = int.parse(datePart.substring(0, 4));
  int month = int.parse(datePart.substring(4, 6));
  int day = int.parse(datePart.substring(6, 8));
  int hour = int.parse(timePart.substring(0, 2));
  int minute = int.parse(timePart.substring(2, 4));
  int second = int.parse(timePart.substring(4, 6));

  DateTime dateTime = DateTime(year, month, day, hour, minute, second);

  return dateTimeToTimestamp(dateTime);
}

String ipgTimeToTimestamp(String ipgTime){
  DateTime dateTime = DateTime.parse(ipgTime);

  String postgresTimestamp = dateTime.toIso8601String().replaceAll('T', ' ').split('.')[0];

  String microseconds = dateTime.microsecond.toString().padLeft(6, '0').substring(0, 6);

  postgresTimestamp += '.$microseconds';

  return postgresTimestamp;
}