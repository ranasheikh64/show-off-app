import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'firebase_options.dart';
import 'package:frontend/features/chat/controllers/chat_controller.dart';
import 'core/services/push_notification_service.dart';

import 'core/storage/hive_service.dart';
import 'core/constants/app_theme.dart';
import 'routes/app_router.dart';

import 'package:get/get.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'features/call/controllers/call_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VisibilityDetectorController.instance.updateInterval =
      const Duration(milliseconds: 300);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Push Notifications
  await PushNotificationService.initialize();

  await HiveService.init();

  // Initialize Global Controllers
  Get.put(AuthController(), permanent: true); // AuthController manages global state
  Get.lazyPut(() => ChatController(), fenix: true);
  Get.put(CallController(), permanent: true); // CallController for incoming/outgoing calls

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: 'Show Off',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
        );
      },
    );
  }
}
