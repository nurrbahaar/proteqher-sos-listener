import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class SosHelpApp extends StatelessWidget {
  const SosHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProteqHer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: AppRouter.launch,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
