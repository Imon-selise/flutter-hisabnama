import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/constants.dart';
import 'screens/root_screen.dart';

class HishabNamaApp extends StatelessWidget {
  const HishabNamaApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true, scaffoldBackgroundColor: kBg);
    return MaterialApp(
      title: 'হিসাবনামা',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        textTheme: GoogleFonts.hindSiliguriTextTheme(base.textTheme),
      ),
      home: const RootScreen(),
    );
  }
}
