import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleepless_app/screens/play_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<void> _launchEmail() async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'support@coventrylabs.net',
    query: 'subject=Meandering Feedback'
  );
  try {
    if (!await launchUrl(emailLaunchUri)) {
      throw 'Could not launch email';
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error launching email: $e');
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedGender = 'male';
  String? _selectedStory = 'meandering';

  final TextStyle _genderStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16);

  @override void initState() {
    super.initState();
  }

  @override void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: SvgPicture.asset(
            width: 45,
            height: 45,
            'assets/images/logo.svg',
          ),
            backgroundColor: Colors.transparent
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: SafeArea (
          child: SingleChildScrollView (
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 45.0, bottom: 15),
                    child: SvgPicture.asset('assets/images/speakingicon.svg')
                ),
                Container (
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 3,
                        offset: const Offset(0, -2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 13.0),
                    child: CupertinoSlidingSegmentedControl<String>(
                      key: const Key('genderSlider'),
                      backgroundColor: Colors.white10,
                      // Semi-transparent background
                      thumbColor: Colors.white30,
                      // White thumb for better visibility
                      children: {
                        'male': Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Text('Male',
                              key: const Key('maleKey'),
                              style: _genderStyle
                          ),
                        ),
                        'female': Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                          child: Text('Female',
                            key: const Key('femaleKey'),
                            style: _genderStyle,
                          ),
                        ),
                      },
                      onValueChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      groupValue: _selectedGender,
                    ),
                  ),
                ),
                Container (
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: const Offset(0, 0), // changes position of shadow
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                              'assets/images/buttoncontainer.svg'),
                        ),
                        Column(
                            children: [
                              Container (
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Container (
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 3,
                                        offset: const Offset(0, 6), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: MaterialButton(
                                    padding: const EdgeInsets.all(0.0),
                                    key: const Key('meandering'),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: SvgPicture.asset(
                                      'assets/images/meanderingbutton.svg',
                                    ),
                                    onPressed: () {
                                      _selectedStory = 'meandering';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            PlayScreen(selectedGender: _selectedGender,
                                                selectedStory: _selectedStory),
                                          settings: RouteSettings(
                                            name: '${_selectedStory}_${_selectedGender}', // This is the screen name used by Firebase
                                          )),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Container (
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Container (
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 3,
                                        offset: const Offset(0, 6), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: MaterialButton(
                                    padding: const EdgeInsets.all(0.0),
                                    key: const Key('boring'),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: SvgPicture.asset(
                                      'assets/images/boringbutton.svg',
                                    ),
                                    onPressed: () {
                                      _selectedStory = 'boring';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            PlayScreen(selectedGender: _selectedGender,
                                                selectedStory: _selectedStory),
                                            settings: RouteSettings(
                                              name: '${_selectedStory}_${_selectedGender}', // This is the screen name used by Firebase
                                            )),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Container (
                                // padding: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 0,
                                      blurRadius: 3,
                                      offset: const Offset(0, 6), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: MaterialButton(
                                  padding: const EdgeInsets.all(0.0),
                                  key: const Key('port'),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: SvgPicture.asset(
                                    'assets/images/portbutton.svg',
                                  ),
                                  onPressed: () {
                                    _selectedStory = 'weather';
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          PlayScreen(selectedGender: _selectedGender,
                                              selectedStory: _selectedStory),
                                          settings: RouteSettings(
                                            name: '${_selectedStory}_${_selectedGender}', // This is the screen name used by Firebase
                                          )),
                                    );
                                  },
                                ),
                              ),
                            ]
                        ),
                      ]
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 30),
                  child: Container(
                    width: 300,
                    // Remove fixed height
                    constraints: BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Meandering is a project aimed at finding the sweet spot '
                                'for sleep audio through AI generated text-to-speech.\n\n'
                                'If you have any feedback:\n',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.25),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          ElevatedButton(
                            onPressed: _launchEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.withOpacity(0.2),
                            ),
                            child: Text(
                                'support@coventrylabs.net',
                                style: TextStyle(
                                    color: Colors.yellow.withOpacity(0.7)
                                )
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
