import 'package:flutter/material.dart';
import 'package:store/features/auth/data/session_store.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved session on app start
  await SessionStore.loadUser();

  runApp(const MyApp());
}
