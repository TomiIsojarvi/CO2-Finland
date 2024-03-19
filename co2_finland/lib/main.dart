import 'package:flutter/material.dart';
import 'package:co2_finland/screens/home.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Intl.systemLocale = await findSystemLocale();
  initializeDateFormatting();

  runApp(
    const MaterialApp(
      title: "CO2 Finland",
      home: HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fi'),
        Locale('sv'),
        Locale('en'),
      ],
      // locale: Locale(Platform.localeName),
      debugShowCheckedModeBanner: false,
    )
  );
}