import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tajir/core/constants/app_constants.dart';
import 'package:tajir/core/database/hive/hive_service.dart';
import 'package:tajir/core/localization/app_localizations.dart';
import 'package:tajir/core/presentation/screens/main_screen.dart';
import 'package:tajir/core/presentation/widgets/notification_permission_initializer.dart';
import 'package:tajir/core/services/installment_notification_service.dart';
import 'package:tajir/core/services/notification_service.dart';
import 'package:tajir/core/theme/app_theme.dart';
import 'package:tajir/features/installments/data/datasources/installment_local_data_source.dart';
import 'package:tajir/features/installments/data/repositories/installment_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. تهيئة Hive
    await HiveService.init();

    // 2. تهيئة الإشعارات المحلية
    final notificationService = NotificationService.instance;
    await notificationService.initialize();

    // 3. إنشاء طبقة البيانات
    final installmentLocalDataSource = InstallmentLocalDataSource(
      plansBox: HiveService.installmentPlansBox,
      installmentsBox: HiveService.installmentsBox,
    );

    final installmentRepository = InstallmentRepositoryImpl(
      installmentLocalDataSource,
    );

    // 4. جدولة الإشعارات داخل try-catch منفصل لكي لا تعطّل تشغيل التطبيق لو حدث خطأ
    try {
      final installmentNotificationService = InstallmentNotificationService(
        installmentRepository: installmentRepository,
        notificationService: notificationService,
      );
      await installmentNotificationService.scheduleAllInstallmentNotifications();
    
    } catch (e) {
      debugPrint("Notification Scheduling Error: $e");
    }

  } catch (e) {
    debugPrint("App Initialization Error: $e");
  }

  // 5. تشغيل التطبيق في كل الأحوال
  runApp(const TajirApp());
}

class TajirApp extends StatelessWidget {
  const TajirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],

      locale: const Locale('ar'),

      theme: AppTheme.lightTheme,

      home: const NotificationPermissionInitializer(
        child: MainScreen(),
      ),
    );
  }
}