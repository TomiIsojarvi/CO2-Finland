import 'dart:convert';

List<DataValue> dataValueFromJson(String str) =>
    List<DataValue>.from(json.decode(str).map((x) => 
      DataValue.fromJson(x)));

String dataValueToJson(List<DataValue> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

//-----------------------------------------------------------------------------
// DataValue - Used to store data values from API server.
//-----------------------------------------------------------------------------
class DataValue {
  double value;
  String startTime;
  String endTime;
  
  //-----------------------------------
  // DataValue - Constructor
  //-----------------------------------
  DataValue({
      required this.value,
      required this.startTime,
      required this.endTime,
  });

  //-----------------------------------
  // fromJson - Factory to create DataValue-objects from Json.
  //-----------------------------------
  factory DataValue.fromJson(Map<String, dynamic> json) => 
    DataValue(
        value: json["value"]?.toDouble(),
        startTime: json["start_time"],
        endTime: json["end_time"],
    );

  //-----------------------------------
  // toJson - Converts to Json
  //-----------------------------------
  Map<String, dynamic> toJson() => {
      "value": value,
      "start_time": startTime,
      "end_time": endTime,
  };
}