import 'package:http/http.dart' as http;
import 'package:co2_finland/env/env.dart';
import 'package:co2_finland/model/data_value.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

//-----------------------------------------------------------------------------
// ApiService - Handles the data fetching from the API-server.
//-----------------------------------------------------------------------------
class ApiService {
  final int _consumedId = 265;
  final int _productionId = 266;
  
//-----------------------------------
// Shortcut methods to fetch data without knowing the id.
//-----------------------------------
Future<List<DataValue>?> fetchConsumedDataValues(DateTime startDate, 
  DateTime endDate) => fetchDataValues(_consumedId, startDate, endDate);
Future<List<DataValue>?> fetchProductionDataValues(DateTime startDate, 
  DateTime endDate) => fetchDataValues(_productionId, startDate, endDate);

//-----------------------------------
//  fetchDataValues - Fetches the data values based on id, start date and
//                    end date.
//-----------------------------------
Future<List<DataValue>?> fetchDataValues(int id, DateTime startDate, 
  DateTime endDate) async {
    // Request Header
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'x-api-key': Env.fingridApiKey
    };

    // Format the dates to Strings.
    String startTime = DateFormat('yyyy-MM-ddTH:mm:ss').format(startDate);
    String endTime = DateFormat('yyyy-MM-ddTH:mm:ss').format(endDate);

    // API URL Path for data.
    String url = "https://api.fingrid.fi/v1/variable/$id/events/json?"
      "start_time=${startTime}Z&end_time=${endTime}Z";

    try {
      // Fetch the JSON-data and decode.
      var response = await http.get(Uri.parse(url), headers: requestHeaders);
      if (response.statusCode == 200) {
        List<DataValue> dataModel = dataValueFromJson(response.body);
        return dataModel;
      }  
    } catch (e) {
      dev.log(e.toString());
    }

    return null;
  }
}