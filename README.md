# Meandering Sleep App

## Intro

This is the Meandering Sleep Flutter app. You can download it from the [Apple App Store](https://apps.apple.com/us/app/meandering-sleep/), or [Google Play Store](https://play.google.com/store/apps/details?id=net.coventry.sleepless).

## Dev Environment setup

* Testing has not been done with anything higher than Java version 17.0.13
* the Google audio url variable needs to be defined via --dart-define flag for building/testing/running 
* Install [Flutter](https://flutter.dev/)
* Install [Android Studio](https://developer.android.com/studio) with Flutter and Dart plugins
* If you install version 2024.2.1 or higher, you'll need to explicitly configure Flutter to use your Java 17 version. ``` flutter config --jdk-dir PATH-TO-YOUR-JAVA-INSTALLATION ```
* Install [XCode](https://developer.apple.com/xcode/) for iOS dev
* Clone this repo.
* Create a new project for the app in Android Studio. Do this via File->Open and open the root directory of the cloned project from previous command, 'sleepless_app/', which is one level deeper than the repository directory.
* Run ``` flutter create --platforms=ios,android . ``` within the /sleepless_app project directory, to create the ios project directories/project files.
* Install/setup [Firebase Crashlytics/Analytics for Flutter](https://firebase.google.com/docs/crashlytics/get-started?platform=flutter)
* Open Runner in XCode, and...
  * Project:Runner IOS Deployment Target is set to ``` 12.0 ```
  * Target:Runner
    * Ensure your Apple ID is setup for signing
    * Bundle Identifier is set to ``` net.coventry.sleepless ```
    * Background Modes includes ``` Audio ```
* Run ``` flutter doctor ``` to make sure flutter's in good shape.

## Environment Variables
```
GF_GET_AUDIO_URL=https://some-url (all tests/builds)
GS_GET_THUMBNAIL_URL=https://some-other-url (include for production builds)
```

## Running unit tests

`flutter test --dart-define=GF_GET_AUDIO_URL=https://domain/ --dart-define=GS_GET_STORAGE_URL=https://domain/`

## Running integration tests

[Integration tests](https://docs.flutter.dev/cookbook/testing/integration/introduction) currently have to be run manually, and with a virtual device running. I've only ever done it from within Android Studio (again, with a virtual device running).

```
flutter test integration_test/app_test.dart --dart-define=GF_GET_AUDIO_URL=https://domain/
```

## Running the app

### On Android Emulator

* In Android Studio, setup an emulator in the `Device Manager`.
* Run it using the play button in `Device Manager`
* It switches to the `Running Devices` view.
* Select the emulator from the device list next to the run configuration.
* Run `main.dart`

### On iOS Simulator (MacOS+XCode required)

* Start the `iOS Simulator` app
* Install and Run the iPhone Simulator of your choice.
* In Android Studio, select the simulator from the device list next to the run configuration.
* Run `main.dart`

### On Physical iOS device (e.g. your iPhone)

* Connect device to your computer via USB
* Select your device in Android Studio's device list
* Run `main.dart`
* the Runner scaffolding will get built in Android Studio, then handed off to Xcode for running.
* the first time you go through this, you'll have to associate your signing/certificate with the project, before the code can run on the device. check the Run output window in Android Studio for the steps to do this, but, they're below as well.
  * Update the build configuration via XCode. [here's a general walkthrough on how to do it](https://developer.apple.com/documentation/Xcode/configuring-the-build-settings-of-a-target)
  * Select the Runner Project
  * Select the Runner Target
  * Select "Signging and Capabilities"
     * Select a team (right now we're using our personal accounts), or Add Account and add your Apple ID (create a developer one if you don't want to use your personal one).
     * Bundle identifier should be prefilled.
* manually run the Runner project (Play button top-left window area). you should get an error in XCode about not being able to run, and your device should ask if you want to Trust the developer. you can adjust these settings in Settings->General->VPN Device Management.
* manually run again and you should be good to go. going forward, you won't have to do all of the project/signing setup/trusting again (unless those settings change).
* if you run into issues with macos not letting you run iproxy, idevicesyslog, and maybe others, checkout how to manually authorize them at https://medium.com/p/7aa1f89f61aa . relevant example commands below from the article. you can find your Flutter path by running `flutter doctor -v`

```
# iproxy
sudo xattr -d com.apple.quarantine "Flutter_Path/bin/cache/artifacts/usbmuxd/iproxy"
# idevicesyslog
sudo xattr -d com.apple.quarantine "Flutter_Path/bin/cache/artifacts/libimobiledevice/idevicesyslog"
# Dart
sudo xattr -d com.apple.quarantine "Flutter_Path/bin/cache/dart-sdk/bin/dart"
# idevice_id
sudo xattr -d com.apple.quarantine "Flutter_Path/bin/cache/artifacts/libimobiledevice/idevice_id"
# ideviceinfo
sudo xattr -d com.apple.quarantine "Flutter_Path/bin/cache/artifacts/libimobiledevice/ideviceinfo"
# idevicename
sudo xattr -d com.apple.quarantine "Flutter_Path/bin/cache/artifacts/libimobiledevice/idevicename"
# idevicescreenshot
sudo xattr -d com.apple.quarantine "Flutter_Path/bin/cache/artifacts/libimobiledevice/idevicescreenshot"

etc
```
  

### On Android

* Configure device for developer mode (see Android/iOS documentation for that)
* Connect to your computer
* Select in Android Studio's device list
* Run `main.dart`

### On Chrome Simulator (use at your own risk)

* I've found Chrome to work even though we haven't explicitly indicate that the app can build/run there.
* major issue though is that Chrome doesn't support mp3 files for audio playback, so while you can run/test the UI, audio won't play.

### Formatting

We use a line length of `100` characters, which is good enough to show two files side by side on a modern 27 inch
screen.
Line length can be set in Android Studio `Preferences > Editor > Code Style > Dart`.

If your prefer a different line length, feel free to update the `Tasks.mk` to your team's liking
and have developers configure their IDE as well.

### Cyclic dependencies

Make sure your imports are relative only for files in the same folder, otherwise use `package:` imports.
