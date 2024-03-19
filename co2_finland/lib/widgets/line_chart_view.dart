import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:co2_finland/model/date_time_value.dart';
import 'package:co2_finland/enums.dart';
import 'package:intl/intl.dart';

//-----------------------------------------------------------------------------
// LineChartView - Line Chart View Widget
//-----------------------------------------------------------------------------
class LineChartView extends StatefulWidget {
  final List<DateTimeValue> consumedValues;
  final List<DateTimeValue> productionValues;
  final AverageFilter averageFilterInterval;
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  //-----------------------------------
  // LineChartView - Constructor
  //-----------------------------------
  const LineChartView({
    super.key, 
    required this.consumedValues, 
    required this.productionValues,
    required this.averageFilterInterval,
    required this.initialStartDate,
    required this.initialEndDate
  });

  @override
  State<StatefulWidget> createState() =>_LineChartViewState();
}

//-----------------------------------------------------------------------------
// _LineChartViewState - State for the Line Chart View Widget
//-----------------------------------------------------------------------------
class _LineChartViewState extends State<LineChartView> {
  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  
  late final AverageFilter _averageFilterInterval = 
    widget.averageFilterInterval;

  late final DateTime _initialStartDate = widget.initialStartDate;
  late final DateTime _initialEndDate = widget.initialEndDate;

  //-----------------------------------
  // initState - Initializes the state.
  //-----------------------------------
  @override
  void initState() {
    
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );

    _zoomPanBehavior = ZoomPanBehavior(
      zoomMode: ZoomMode.x,
      enablePinching: true,
      enablePanning: true,
      enableMouseWheelZooming : true
    );

    super.initState();
  }

  //-----------------------------------
  // _xAxisLabelFormatter - Formats the X-Axis.
  //-----------------------------------
  ChartAxisLabel _xAxisLabelFormatter(AxisLabelRenderDetails args) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(args.value.toInt());
    String text = "";
    TextStyle textStyle = args.textStyle;

    switch (args.currentDateTimeIntervalType) {
      //-------------------------------
      // Minutes
      //-------------------------------
      case DateTimeIntervalType.minutes:
        // Don't show labels if average filter is hour, day or month.
        if (_averageFilterInterval == AverageFilter.hour ||
          _averageFilterInterval == AverageFilter.day || 
          _averageFilterInterval == AverageFilter.month) 
        {
          break;
        }

        // Make the previous date by subtracting the interval.
        DateTime lastDate = date.subtract(
          Duration(minutes: args.axis.visibleInterval.toInt())
        );

        // Has the day changed?
        if (date.day == lastDate.day) {
          // No...
          text = DateFormat.jm().format(date);
        } else {
          // Yes...
          text = DateFormat.MEd().format(date);
          textStyle = const TextStyle(fontWeight: FontWeight.bold);
        }
      break;
      //-------------------------------
      // Hours
      //-------------------------------
      case DateTimeIntervalType.hours:
        // Don't show labels if average filter is day or month.
        if (_averageFilterInterval == AverageFilter.day || 
          _averageFilterInterval == AverageFilter.month) 
        {
          break;
        }

        // Make the previous date by subtracting the interval.
        DateTime lastDate = date.subtract(
          Duration(hours: args.axis.visibleInterval.toInt())
        );

        // Has the day changed?
        if (date.day == lastDate.day) {
          // No...
          text = DateFormat.jm().format(date);
        } else {
          // Yes...
          text = DateFormat.MMMd().format(date);
          textStyle = const TextStyle(fontWeight: FontWeight.bold);
        }
      break;
      //-------------------------------
      // Days
      //-------------------------------
      case DateTimeIntervalType.days:
        // Don't show labels if average filter is month.
        if (_averageFilterInterval == AverageFilter.month) 
        {
          break;
        }
        // Make the previous date by subtracting the interval.
        DateTime lastDate = date.subtract(
          Duration(days: args.axis.visibleInterval.toInt())
        );

        // Has the month changed?
        if (date.month == lastDate.month) {
          // No...
          text = DateFormat.MEd().format(date);
        } else {
          // Yes...
          text = DateFormat.MMMd().format(date);
          textStyle = const TextStyle(fontWeight: FontWeight.bold);
        }
      break;
      //-------------------------------
      // Months
      //-------------------------------
      case DateTimeIntervalType.months:
        DateTime lastDate = DateTime(date.year, date.month - 1);

        // Has the year changed?
        if (date.year == lastDate.year) {
          // No...
          text = DateFormat.MMMM().format(date);
        } else {
          // Yes...
          text = DateFormat.yMMM().format(date);
          textStyle = const TextStyle(fontWeight: FontWeight.bold);
        }
      break;
      default:
    }

    return ChartAxisLabel(text, textStyle);
  }
 
  //-----------------------------------
  // build
  //-----------------------------------
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: const ChartTitle(text: 'Emission factors for electricity',),
      legend: const Legend(isVisible: true),
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      enableAxisAnimation: true,
      onActualRangeChanged: (rangeChangedArgs) {
      },

      // Line series...
      series: <CartesianSeries>[
        FastLineSeries<DateTimeValue, DateTime>(
          name: 'Consumption',
          dataSource: widget.consumedValues,
          xValueMapper: (DateTimeValue value, _) => value.startTime,
          yValueMapper: (DateTimeValue value, _) => value.value,
          enableTooltip: true,
        ),
        FastLineSeries<DateTimeValue, DateTime>(
          name: 'Production',
          dataSource: widget.productionValues,
          xValueMapper: (DateTimeValue value, _) => value.startTime,
          yValueMapper: (DateTimeValue value, _) => value.value,
          enableTooltip: true,
        ),
       
      ],
      // X-axis...
      primaryXAxis: DateTimeAxis(
        initialVisibleMaximum: _initialEndDate,
        initialVisibleMinimum: _initialStartDate,
        axisLabelFormatter: _xAxisLabelFormatter,
      ),
      // Y-axis...
      primaryYAxis: NumericAxis(
        anchorRangeToVisiblePoints: false,
        title: const AxisTitle(text: 'gCO2/kWh'),
        enableAutoIntervalOnZooming: false,
        numberFormat: NumberFormat("###.###"),
      ),
      // Edit header for the Trackball Tooltip...
      onTrackballPositionChanging: (TrackballArgs args) {
        DateTime date = args.chartPointInfo.chartPoint!.x;

        // Change UTC-time to local time.
        date = date.toLocal();

        switch (_averageFilterInterval) {
          case AverageFilter.none:
          case AverageFilter.hour:
            args.chartPointInfo.header = DateFormat.yMd().add_jm().format(date);
            break;

          case AverageFilter.day:
            args.chartPointInfo.header = DateFormat.yMd().format(date);
            break;

          case AverageFilter.month:
            args.chartPointInfo.header = DateFormat.yMMM().format(date);
            break;
          default:
        }
      },
    );
  }
}