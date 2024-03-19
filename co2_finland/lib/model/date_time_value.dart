//-----------------------------------------------------------------------------
// DateTimeValue - Class to store DataValues as DateTime -values.
//-----------------------------------------------------------------------------
class DateTimeValue {
  double value;
  DateTime startTime;
  DateTime endTime;

  DateTimeValue({
    required this.value,
    required this.startTime,
    required this.endTime
  });
}