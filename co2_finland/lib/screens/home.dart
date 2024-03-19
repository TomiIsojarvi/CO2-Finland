import 'package:flutter/material.dart';
import 'package:co2_finland/widgets/date_picker.dart';
import 'package:co2_finland/enums.dart';
import 'package:co2_finland/screens/info.dart';

//-----------------------------------------------------------------------------
// HomePage - Home Page for the application
//-----------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({
    super.key, 
  });

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

//-----------------------------------------------------------------------------
// _HomePageState - State for the Home Page
//-----------------------------------------------------------------------------
class _HomePageState extends State<HomePage> {

  // List of items in Quick Search dropdown menu.
  final _quickSearchItems = ['1 hour', '3 hours', '6 hours', '12 hours', 
  '1 day', '3 days', '1 week', '2 weeks', '1 month', '3 months'];

  // List of items in Average Filter dropdown menu.
  final _averageFilterItems = ['None', 'Hour', 'Day', 'Month'];

  // List of items in Time Interval dropdown menu.
  final _timeIntervalItems = ['All', '15 minutes', '30 minutes', '1 hour', 
  '3 hours', '6 hours', '12 hours', '1 day', '3 days', '1 week', '2 weeks', 
  '1 month', '3 months'];

  // Selected items...
  String? _selectedQuickSearchItem;
  String? _selectedAverageFilterItem;
  String? _selectedTimeIntervalItem;
  
  // First records of data are from this specific date.
  final DateTime _firstDate = DateTime(2019, 6, 24);

  // User's selected start and end dates.
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Where from?
  WhereFrom _whereFrom = WhereFrom.fromEnd;

  //-----------------------------------
  // initState - Initializes the state.
  //-----------------------------------
  @override
  initState() {
    super.initState();
  }

  //-----------------------------------
  // _quickSearch - Go to info page and start fetching data. Use Quick Search.
  //-----------------------------------
  _quickSearch() {
    DateTime startDateTime = DateTime.now();

    switch (_selectedQuickSearchItem) {
      case '1 hour':
        startDateTime = startDateTime.subtract(const Duration(hours: 1));
        break;
      case '3 hours':
        startDateTime = startDateTime.subtract(const Duration(hours: 3));
        break;
      case '6 hours':
        startDateTime = startDateTime.subtract(const Duration(hours: 6));
        break;
      case '12 hours':
        startDateTime = startDateTime.subtract(const Duration(hours: 12));
        break;
      case '1 day':
        startDateTime = startDateTime.subtract(const Duration(days: 1));
        break;
      case '3 days':
        startDateTime = startDateTime.subtract(const Duration(days: 3));
        break;
      case '1 week':
        startDateTime = startDateTime.subtract(const Duration(days: 7));
        break;
      case '2 weeks':
        startDateTime = startDateTime.subtract(const Duration(days: 14));
        break;
      case '1 month':
        startDateTime = DateTime(startDateTime.year, startDateTime.month - 1);
        break;
      case '3 months':
        startDateTime = DateTime(startDateTime.year, startDateTime.month - 3);
        break;
      default:
        startDateTime = DateTime.now();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(
          startDate: startDateTime,
          endDate: DateTime.now(),
          averageFilterInterval: AverageFilter.none,
          intervalType: IntervalType.all,
          interval: 0,
          whereFrom: WhereFrom.fromEnd,
        ),
      ),
    );
  }

  //-----------------------------------
  // _advancedSearch - Go to info page and start fetching data. Use Advanced
  //                   Search.
  //-----------------------------------
  _advancedSearch() {
    AverageFilter averageFilter;
    IntervalType intervalType;
    int interval;

    switch (_selectedAverageFilterItem) {
      case "None":
        averageFilter = AverageFilter.none; break;
      case "Hour":
        averageFilter= AverageFilter.hour; break;
      case "Day":
        averageFilter = AverageFilter.day; break;
      case "Month":
        averageFilter = AverageFilter.month; break;
      default:
        averageFilter = AverageFilter.none;
    }

    switch (_selectedTimeIntervalItem) {
      case 'All':
        intervalType = IntervalType.all; interval = 0; break;
      case '15 minutes':
        intervalType = IntervalType.minute; interval = 15; break;
      case '30 minutes':
        intervalType = IntervalType.minute; interval = 30; break;
      case '1 hour':
        intervalType = IntervalType.hour; interval = 1; break;
      case '3 hours':
        intervalType = IntervalType.hour; interval = 3; break;
      case '6 hours':
        intervalType = IntervalType.hour; interval = 6; break;
      case '12 hours':
        intervalType = IntervalType.hour; interval = 12; break;
      case '1 day':
        intervalType = IntervalType.day; interval = 1; break;
      case '3 days':
        intervalType = IntervalType.day; interval = 3; break;
      case '1 week':
        intervalType = IntervalType.day; interval = 7; break;
      case '2 weeks':
        intervalType = IntervalType.day; interval = 14; break;
      case '1 month':
        intervalType = IntervalType.month; interval = 1; break;
      case '3 months':
        intervalType = IntervalType.month; interval = 3; break;
      default:
        intervalType = IntervalType.all; interval = 0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(
          startDate: _startDate,
          // Let's add 23:59:59 to the end date to get the time just 
          // before midnight.
          endDate: _endDate.add(const 
            Duration(hours: 23, minutes: 59, seconds: 59)
          ),
          averageFilterInterval: averageFilter,
          intervalType: intervalType,
          interval: interval,
          whereFrom: _whereFrom,
        ),
      ),
    );
  }

  //-----------------------------------
  // _quickSearchTile - Builds the Quick Search Tile
  //-----------------------------------
  ExpansionTile _quickSearchTile() {
    return ExpansionTile(
      childrenPadding: const EdgeInsets.symmetric(vertical: 10),
      initiallyExpanded: true,
      title: const Text("Quick Search"),
      children: <Widget>[
        DropdownButton(
          hint: const Text('Search last...'),
          value: _selectedQuickSearchItem,
          items: _quickSearchItems.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item)
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
            _selectedQuickSearchItem = newValue;
            });
          },
        ),
        // Quick Search button
        ElevatedButton.icon(
          onPressed: _quickSearch,
          icon: const Icon(Icons.search),
          label: const Text("Quick Search"),
        ),
      ],
    );
  }

  //-----------------------------------
  // _advancedSearchTile - Builds the Advanced Search Tile
  //-----------------------------------
  ExpansionTile _advancedSearchTile() {
    return ExpansionTile(
      onExpansionChanged: (value) {
        setState(() {
          _startDate = DateTime.now();
          _endDate = DateTime.now();
        });
      },
      childrenPadding: const EdgeInsets.symmetric(vertical: 10),
      title: const Text("Advanced Search"),
      children: <Widget>[
        
        // Start Date Picker -widget
        DatePicker(
          firstDate: _firstDate,
          lastDate: _endDate,
          label: "Start date",
          onDateChanged: (date) => setState(() {
            _startDate = date;
          }),
        ),

        // End Date Picker -widget
        DatePicker(
          firstDate:_startDate,   // Notice: _startDate, not _firstDate
          lastDate: DateTime.now(),
          label: "End date",
          onDateChanged: (date) => setState(() {
            _endDate = date;
          }),
        ),

        // Where From? -radio buttons
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                title: const Text('From start'),
                value: WhereFrom.fromStart, 
                groupValue: _whereFrom, 
                onChanged: (WhereFrom? value) {
                  setState(() {
                    _whereFrom = value!;
                  });
                }
              )
            ),
            Expanded(
              child: RadioListTile(
                title: const Text('From end'),
                value: WhereFrom.fromEnd, 
                groupValue: _whereFrom, 
                onChanged: (WhereFrom? value) {
                  setState(() {
                    _whereFrom = value!;
                  });
                }
              )
            ),
          ],
        ),
        Row(
          children: [
            // Average Filter
            Expanded(
              child: ListTile(
                title: const Text('Average Filter: '),
                subtitle: DropdownButton(
                  hint: const Text('None'),
                  value: _selectedAverageFilterItem,
                  items: _averageFilterItems.map((String item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item)
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAverageFilterItem = newValue;
                    });
                  },
                ),
              ),
            ),

            // Time Interval
            Expanded(
            child:  ListTile(
              title: const Text('Time Interval: '),
              subtitle: DropdownButton(
                hint: const Text('All'),
                value: _selectedTimeIntervalItem,
                items: _timeIntervalItems.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item)
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTimeIntervalItem = newValue;
                  });
                },
                ),
              ),
            ),
          ],
        ),

        // Advanced Search button
        ElevatedButton.icon(
          onPressed: _advancedSearch,
          icon: const Icon(Icons.search),
          label: const Text("Search"),
        ),
      ],
    );
  }

  //-----------------------------------
  // build
  //-----------------------------------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: 
            <Widget>[
              const Column(
                children: [
                  Text("CO2 Finland", 
                  style: TextStyle(fontSize: 32, ),
                  ),
                  Text("Powered by Fingrid", 
                  style: TextStyle(fontSize: 15, ),
                  ),
                ],
              ),
              // Quick Search
              _quickSearchTile(),
              // Advanced Search
              _advancedSearchTile(),
            ],
          )  
        ),
      ),
    );
  }
}