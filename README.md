# Sleepless App

## Intro

This is the Sleepless Flutter App.

## Dev Environment setup

* Install [Flutter](https://flutter.dev/)
* Install [Android Studio](https://developer.android.com/studio) with Flutter and Dart plugins
* Install [XCode](https://developer.apple.com/xcode/) for iOS dev
* Create a new project for the app in Android Studio. Do this via File->Open and open the root directory of the project, 'sleepless_app/', which is one level deeper than the repository directory.
* Run ``` make install ``` to make sure flutter dependencies are up-to-date
* Run ``` flutter doctor ``` to make sure flutter's in good shape.


## Running checks

This checks formatting, runs tests and checks for dependency cycles. From the root repository directory where the Makefile sits run the following.

```
make check
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
  * Select the Runner Project
  * Select the Runner Target
  * Select "Signging and Capabilities"
     * Select a team (right now we're using our personal accounts), or Add Account and add your Apple ID (create a developer one if you don't want to use your personal one).
     * Bundle identifier should be prefilled.
* manually run the Runner project (Play button top-left window area). you should get an error in XCode about not being able to run, and your device should ask if you want to Trust the developer. you can adjust these settings in Settings->General->VPN Device Management.
* manually run again and you should be good to go. going forward, you won't have to do all of the project/signing setup/trusting again (unless those settings change).
  

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
