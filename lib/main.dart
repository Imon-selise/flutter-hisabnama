import 'package:flutter/material.dart';
import 'store/store.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.I.load();
  runApp(const HishabNamaApp());
}
