import 'package:sleepless_app/utils.dart';
import 'package:test/test.dart';

void main() {
  test('Test correct days of week', ()
  {
     expect(getDayOfWeekString(DateTime(2024, 1, 1)), 'Monday');
     expect(getDayOfWeekString(DateTime(2024, 1, 2)), 'Tuesday');
     expect(getDayOfWeekString(DateTime(2024, 1, 3)), 'Wednesday');
     expect(getDayOfWeekString(DateTime(2024, 1, 4)), 'Thursday');
     expect(getDayOfWeekString(DateTime(2024, 1, 5)), 'Friday');
     expect(getDayOfWeekString(DateTime(2024, 1, 6)), 'Saturday');
     expect(getDayOfWeekString(DateTime(2024, 1, 7)), 'Sunday');

  });

  test('Make sure we can build audio URLs', ()
  {
    // DO NOT test the actual URL contents for obfuscation purposes
    // simply test for some semblance of a URI to make sure the app is being
    // built with the necessary environment variables
    expect(Uri.parse(const String.fromEnvironment('GF_GET_AUDIO_URL')).hasAbsolutePath, true);
  });

  test('Make sure we can build thumbnail audio URLs', ()
  {
    // DO NOT test the actual URL contents for obfuscation purposes
    // simply test for some semblance of a URI to make sure the app is being
    // built with the necessary environment variables
    expect(Uri.parse(const String.fromEnvironment('GS_GET_THUMBNAIL_URL')).hasAbsolutePath, true);
  });

  test('Make sure we can get audio list json URL', ()
  {
    // DO NOT test the actual URL contents for obfuscation purposes
    // simply test for some semblance of a URI to make sure the app is being
    // built with the necessary environment variables
    expect(Uri.parse(const String.fromEnvironment('GF_GET_AUDIO_LIST_JSON_URL')).hasAbsolutePath, true);
  });
}