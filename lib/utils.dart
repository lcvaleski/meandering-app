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

    if (appleApiKey.isEmpty || googleApiKey.isEmpty) {
      throw Exception("RevenueCat API keys must not be empty!");
    }

    final PurchasesConfiguration config;
    if (Platform.isIOS) {
      logger.d('Using Apple API Key');
      config = PurchasesConfiguration(appleApiKey);
    } else if (Platform.isAndroid) {
      logger.d('Using Google API Key');
      config = PurchasesConfiguration(googleApiKey);
    } else {
      logger.e('Unsupported platform: RevenueCat NOT configured');
      return;
    }
    await Purchases.configure(config);
    logger.d('RevenueCat SDK configured successfully for ${Platform.operatingSystem}');

  } catch (e, stack) {
    logger.e('Failed to configure RevenueCat SDK', error: e, stackTrace: stack);
    rethrow;
  }
}