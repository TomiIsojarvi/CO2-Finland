import 'package:flutter/material.dart';
import 'package:co2_finland/enums.dart';
import 'package:co2_finland/api/api_service.dart';
import 'package:co2_finland/model/data_value.dart';
import 'package:co2_finland/model/date_time_value.dart';
import 'package:co2_finland/widgets/line_chart_view.dart';


//-----------------------------------------------------------------------------
// InfoPage - Info Page
//-----------------------------------------------------------------------------
class InfoPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final AverageFilter averageFilterInterval;
  final IntervalType intervalType;
  final WhereFrom whereFrom;
  final int interval;

  const InfoPage(
    {
      super.key,
      required this.startDate,
      required this.endDate,
      required this.averageFilterInterval,
      required this.intervalType,
      required this.interval,
      required this.whereFrom
    }
  );

  @override
  State<InfoPage> createState() => _InfoPageState();
}

//-----------------------------------------------------------------------------
// _InfoPageState - State for the Info Page
//-----------------------------------------------------------------------------
class _InfoPageState extends State<InfoPage> {
  final ApiService _apiService = ApiService();

  // Fetched data...
  late Future<List<DataValue>?> _consumedValues;
  late Future<List<DataValue>?> _productionValues;

  // Averaged Filtered data...
  List<DateTimeValue> _filteredConsumedValues = [];
  List<DateTimeValue> _filteredProductionValues = [];

  // Selected AverageFilter...
  AverageFilter _averageFilterInterval = AverageFilter.none;

  // Time interval...
  late IntervalType _intervalType;
  late int _interval;


  //-----------------------------------
  // initState - Initializes the state.
  //-----------------------------------
  @override
  void initState() {
    DateTime startDate = widget.startDate;
    DateTime endDate = widget.endDate;

    // Channge local time to UTC-time.
    startDate = startDate.toUtc();
    endDate = endDate.toUtc();

    // Fetch the data.
    _consumedValues = 
      _apiService.fetchConsumedDataValues(startDate, endDate);
    _productionValues = 
      _apiService.fetchProductionDataValues(startDate, endDate);

    // Read and store the average filter interval from the home screen.
    _averageFilterInterval = widget.averageFilterInterval;

    // Read and store the time interval from the home screen.
    _intervalType = widget.intervalType;
    _interval = widget.interval;

    super.initState();
  }

  //-----------------------------------
  // _filterByAverage - Method that filters and averages the data by a
  //                    average filter interval. Returned values are converted 
  //                    to a list of DateTimeValues.
  //-----------------------------------
  List<DateTimeValue> _filterByAverage(
    AverageFilter averageFilterInterval, List<DataValue>? dataValues) 
  {
    // Check for null list...
    if (dataValues == null) {
      return [];
    }

    // Parse dates from Strings and convert to local time.
    DateTime currentStartDate = 
      DateTime.parse(dataValues.first.startTime).toLocal();
    DateTime currentEndDate = 
      DateTime.parse(dataValues.first.endTime).toLocal();

    // Variables for calculating average.
    int numOfSamples = 0;
    double sum = 0;
    double average = 0;

    List<DateTimeValue> filteredValues = [];
    int currentInterval = 0;

    DateTime date = currentStartDate;

    switch (averageFilterInterval) {
      // If NO filtering, convert the data to DateTimeValue-list and return...
      case AverageFilter.none:
        for (DataValue elem in dataValues) {
          DateTime parsedStartDate = DateTime.parse(elem.startTime).toLocal();
          DateTime parsedEndDate = DateTime.parse(elem.endTime).toLocal();

          filteredValues.add(DateTimeValue(
            value: elem.value, 
            startTime: parsedStartDate, 
            endTime: parsedEndDate
          ));
        }

        return filteredValues;

      // Otherwise...
      case AverageFilter.hour:
        currentInterval = date.hour; break;
      case AverageFilter.day:
        currentInterval = date.day; break;
      case AverageFilter.month:
        currentInterval = date.month; break;
      default:
        currentInterval = 0;
    }

    // Filter and convert data. //
    for (DataValue elem in dataValues) {
      int interval;

      switch (averageFilterInterval) {

        case AverageFilter.hour:
          interval = DateTime.parse(elem.startTime).toLocal().hour;
          break;

        case AverageFilter.day:
          interval = DateTime.parse(elem.startTime).toLocal().day;
          break;

        case AverageFilter.month:
          interval = DateTime.parse(elem.startTime).toLocal().month;
          break;

        default:
          interval = 0;
      }

      // Has the interval changed? 
      if (interval == currentInterval) {
        // No...
        numOfSamples++;
        sum += elem.value;
        currentEndDate = DateTime.parse(elem.endTime).toLocal();
      } else { 
        // Yes... 
        // Calculate the average.
        average = sum / numOfSamples;

        // Add to the filtered values list...
        filteredValues.add(
          DateTimeValue(
            value: average, 
            startTime: currentStartDate, 
            endTime: currentEndDate,
          )
        );

        // ... and reset to the next interval data.
        currentStartDate = DateTime.parse(elem.startTime).toLocal();
        currentEndDate = DateTime.parse(elem.endTime).toLocal();
        sum = elem.value;
        currentInterval = interval;  
        numOfSamples = 1;
      }
    }

    // Add the last interval data to the filteredValues-list.
    average = sum / numOfSamples;
    filteredValues.add(
      DateTimeValue(
        value: average, 
        startTime: currentStartDate, 
        endTime: currentEndDate
      )
    );

    // Return the filtered and converted data values.
    return filteredValues;
  }

  //-----------------------------------
  // _appBar - Builds the App Bar.
  //-----------------------------------
  AppBar _appBar() {
    return AppBar(
      title: const Text("Results"),
      actions: [
        // AppBar's Popup Menu Button
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'NONE',
                child: Text('None'),
            ),
            const PopupMenuItem(
                value: 'HOUR',
                child: Text('Hour'),
            ),
            const PopupMenuItem(
                value: 'DAY',
                child: Text('Day'),
            ),
            const PopupMenuItem(
                value: 'MONTH',
                child: Text('Month'),
            ),
          ],
          // When Popup Menu Item is selected...
          onSelected: (value) => setState(() {
            switch (value) {
              // None selected
              case 'NONE':
               setState(() {
                  _averageFilterInterval = AverageFilter.none;
               }); 
                break;
              // By hours selected
              case 'HOUR':
               setState(() {
                  _averageFilterInterval = AverageFilter.hour;
               }); 
                break;
              // By days selected
              case 'DAY':
                setState(() {
                  _averageFilterInterval = AverageFilter.day;
                }); 
              // By months selected
              case 'MONTH':
                setState(() {
                  _averageFilterInterval = AverageFilter.month;
                }); 
                break;
              // Default
              default:
            }
          }),
        ),
      ],
    );
  }

  //-----------------------------------
  // _lineChartView - Builds the Line Chart View.
  //-----------------------------------
  LineChartView _lineChartView(
    List<DateTimeValue> consumed, List<DateTimeValue> production
  ) {
    DateTime initialStartDateTime;
    DateTime initialEndDateTime;

    // If there's only one value in the list, draw a straight line by copying 
    // the first value and changing it's start time to end time...
    if (consumed.length == 1) {
      consumed.add(DateTimeValue(
        startTime: consumed.first.endTime, 
        endTime: consumed.first.endTime, 
        value: consumed.first.value));
      production.add(DateTimeValue(
        startTime: production.first.endTime, 
        endTime: production.first.endTime, 
        value: production.first.value));
    }

    // Are we starting from the end or from the start of the data.
    if (widget.whereFrom == WhereFrom.fromEnd) {
      initialEndDateTime = consumed.last.endTime;

      switch (_intervalType) {
        case IntervalType.all:
          initialStartDateTime = consumed.first.startTime; break;
        case IntervalType.minute:
          initialStartDateTime = consumed.last.startTime.subtract(
            Duration(minutes: _interval)); break;
        case IntervalType.hour:
          initialStartDateTime = consumed.last.startTime.subtract(
            Duration(hours: _interval)); break;
        case IntervalType.day:
          initialStartDateTime = consumed.last.startTime.subtract(
            Duration(days: _interval)); break;
        case IntervalType.month:
          initialStartDateTime = DateTime(consumed.last.startTime.year, 
            consumed.last.startTime.month - _interval); break;
        default:
          initialStartDateTime = consumed.first.startTime;
      }
    } else {
      initialStartDateTime = consumed.first.startTime;

      switch (_intervalType) {
        case IntervalType.all:
          initialEndDateTime = consumed.last.endTime; break;
        case IntervalType.minute:
          initialEndDateTime = consumed.first.endTime.add(
            Duration(minutes: _interval)); break;
        case IntervalType.hour:
          initialEndDateTime = consumed.first.endTime.add(
            Duration(hours: _interval)); break;
        case IntervalType.day:
          initialEndDateTime = consumed.first.endTime.add(
            Duration(days: _interval)); break;
        case IntervalType.month:
          initialEndDateTime = DateTime(consumed.first.endTime.year, 
            consumed.first.endTime.month + _interval); break;
        default:
          initialEndDateTime = consumed.last.endTime;
      }
    }

    // Return the Line Chart View.
    return LineChartView(
      consumedValues: consumed, 
      productionValues: production, 
      averageFilterInterval: _averageFilterInterval,
      initialStartDate: initialStartDateTime,
      initialEndDate: initialEndDateTime
    );
  }

  //-----------------------------------
  // build
  //-----------------------------------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // App Bar
        appBar: _appBar(),
        // Body
        body: FutureBuilder(
          future: Future.wait([_consumedValues, _productionValues]), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator()
              );
            } else {
              // Create filtered values...
              _filteredConsumedValues = _filterByAverage(
                _averageFilterInterval, snapshot.data![0]);
              _filteredProductionValues = _filterByAverage(
                _averageFilterInterval, snapshot.data![1]);
              
              return _lineChartView(_filteredConsumedValues, 
                _filteredProductionValues);
            }
          }
        )
      )
    );
  }
}