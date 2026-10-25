import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/constants.dart';
import 'package:azmiu_app/core/theme/app_theme.dart';
import 'package:azmiu_app/presentation/widgets/app_blocker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const AzmiuApp());
}

class AzmiuApp extends StatelessWidget {
  const AzmiuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // BÜTÜN TƏTBİQİ PƏRDƏ İLƏ ƏHATƏ EDİRİK
      builder: (context, child) {
        return AppBlocker(child: child ?? const SizedBox.shrink());
      },
    );
  }
}