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
    
    if (Platform.isIOS || Platform.isMacOS) {
      logger.d('Configuring for Apple Store');
      final config = PurchasesConfiguration(appleApiKey);
      await Purchases.configure(config);
    } else if (Platform.isAndroid) {
      const useAmazon = bool.fromEnvironment('amazon');
      logger.d('Configuring for ${useAmazon ? "Amazon" : "Play"} Store');
      final config = PurchasesConfiguration(googleApiKey);
      await Purchases.configure(config);
    }
    logger.i('RevenueCat SDK configured successfully');
  } catch (e, stack) {
    logger.e('Failed to configure RevenueCat SDK', error: e, stackTrace: stack);
    rethrow;
  }
}