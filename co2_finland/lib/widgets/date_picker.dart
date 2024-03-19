import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

//-----------------------------------------------------------------------------
// DatePicker - Date Picker Widget-class
//-----------------------------------------------------------------------------
class DatePicker extends StatefulWidget {
  final String? label;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateChanged; // Callback for date change event

  //-----------------------------------
  // DatePicker - Constructor
  //-----------------------------------
  const DatePicker(
    {
      super.key,
      required this.label,
      required this.firstDate,
      required this.lastDate,
      required this.onDateChanged,
    }
  );

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

//-----------------------------------------------------------------------------
// _DatePickerState - State for the Date Picker Widget
//-----------------------------------------------------------------------------
class _DatePickerState extends State<DatePicker> {
  // Text Field Controller for the Date Picker.
  final TextEditingController _dateInputController = TextEditingController();

  // Selected date.
  DateTime _selectedDate = DateTime.now();

  // Date Format
  late DateFormat _dateFormat;

  //-----------------------------------
  // initState - Initializes the state.
  //-----------------------------------
  @override
  initState() {
    _dateFormat = DateFormat.yMd();
    super.initState();
  }

  //-----------------------------------
  // _openDatePicker - Opens the date picker.
  //-----------------------------------
  _openDatePicker() async {
    // call showDatePicker
    final DateTime? date = await showDatePicker(
      locale: Locale(Platform.localeName.split('_')[0]),  // Set the language
      context: context, 
      initialDate: _selectedDate, 
      firstDate: widget.firstDate, 
      lastDate: widget.lastDate
    );

    // If date was selected...
    if (date != null) {
      // Format the date for the Text Field.
      String formattedDate = _dateFormat.format(date);

      // Update the state
      setState(() {
        _selectedDate = date;
        _dateInputController.text = formattedDate;
      });

      // Call the callback function.
      widget.onDateChanged(_selectedDate);
    }
      
  }

  //-----------------------------------
  // build
  //-----------------------------------
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateInputController,
      decoration: InputDecoration(
        icon: const Icon(Icons.calendar_today), labelText: widget.label),
      readOnly: true,
      onTap: _openDatePicker,
    );
  }
}

