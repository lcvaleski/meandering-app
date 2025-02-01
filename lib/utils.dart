import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sleepless_app/services/logger_service.dart';
import 'dart:io';
import 'revenuecat_constants.dart';

String getDayOfWeekString(DateTime now) {
  final int dayOfWeek = now.weekday;
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return days[dayOfWeek - 1];  // Subtract 1 to match the index
}

Future<void> configurePurchasesSDK() async {
  try {
    logger.i('Configuring RevenueCat SDK');
    await Purchases.setLogLevel(LogLevel.debug);

    if (Platform.isIOS) {
      final config = PurchasesConfiguration(appleApiKey);
      await Purchases.configure(config);
      logger.d('Apple Store: RevenueCat SDK configured successfully');
    } else if (Platform.isAndroid) {
      final config = PurchasesConfiguration(googleApiKey);
      await Purchases.configure(config);
      logger.d('Play Store: RevenueCat SDK configured successfully');
    } else {
      logger.d('Unsupported platform: RevenueCat NOT configured');
    }
  } catch (e, stack) {
    logger.e('Failed to configure RevenueCat SDK', error: e, stackTrace: stack);
    rethrow;
  }
}