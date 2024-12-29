import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:sleepless_app/common.dart';
import 'package:rxdart/rxdart.dart';
import '../utils.dart';
import 'dart:convert';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:http/http.dart' as http;


class PlayScreen extends StatefulWidget {
  final String? selectedGender;
  final String? selectedStory;
  const PlayScreen({super.key, this.selectedGender, this.selectedStory});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with WidgetsBindingObserver {
  bool isPlaying = false;
  late AudioPlayer _player;


  Map<String, dynamic> resourceItems = {};
  Future<void> loadJsonAsset() async {
    final String jsonString = await rootBundle.loadString('assets/resources.json');
    final resData = await jsonDecode(jsonString) as Map<String, dynamic>;
    setState(() {
      resourceItems = resData;
    });
  }

  String audioUrl = '';
  Future<void> fetchAudioUrl() async {
    try {
      final response = await http.post(
        Uri.parse(const String.fromEnvironment('GF_GET_AUDIO_URL')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'day': getDayOfWeekString(DateTime.now()),
          'type': widget.selectedStory,
          'gender': widget.selectedGender,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          audioUrl = data['response'];
        });
        if (audioUrl.isNotEmpty) {
          await _init();
        } else {
          if (kDebugMode) {
            print('Error: audioUrl is empty.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to load audio URL. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in fetchAudioUrl: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    fetchAudioUrl();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          if (kDebugMode) {
            print('A stream error occurred: $e');
          }
        });
    // Try to load audio from a source and catch any errors.
    try {
        await loadJsonAsset();
          final thumbnailUri = const String.fromEnvironment('GS_GET_THUMBNAIL_URL');
          final finalThumbnailUri = thumbnailUri + '${widget.selectedStory}_thumbnail.png';
          final source = AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            // Specify a unique ID for each media item:
            id: '1',
            // Metadata to display in the notification:
            album: 'Sleepless',
            title: '${widget.selectedStory}',
            artUri: Uri.parse(finalThumbnailUri),
          ),
        );

        await _player.setAudioSource(source,
            initialPosition: Duration.zero, preload: true);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audio source: $e');
      }
    }
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true, // This extends the body to be behind the AppBar
        appBar: AppBar(
          key: const Key('playScreenAppBar'),
          backgroundColor: Colors.transparent, // Set background color to transparent
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // Set the back arrow icon
            onPressed: () => Navigator.of(context).pop(), // Defines the action on press
          ),
        ),
        body: Padding (
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container (
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset('assets/images/${widget.selectedStory}_thumbnail.png'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  '${widget.selectedStory}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              // Display play/pause button and volume/speed sliders.
              ControlButtons(_player),
              // Display seek bar. Using StreamBuilder, this widget rebuilds
              // each time the position, buffered position or duration changes.
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition:
                    positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: _player.seek,
                  );
                },
              ),
            ],
          ),
        ),
      );
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        IconButton(
          key: const Key('volumeButton'),
          color: Colors.white,
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              key: const Key('volume'),
              title: 'Adjust volume',
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 50.0,
                height: 50.0,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  strokeWidth: 8.0,
                ),
              );
            } else if (playing != true) {
              return IconButton(
                color: Colors.white,
                icon: const Icon(Icons.play_arrow),
                iconSize: 50.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                color: Colors.white,
                icon: const Icon(Icons.pause),
                iconSize: 50.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                color: Colors.white,
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            key: const Key('speedButton'),
            icon: Text('${snapshot.data?.toStringAsFixed(1)}x',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
            ),
            onPressed: () {
              showSliderDialog(
                context: context,
                key: const Key('speed'),
                title: 'Adjust speed',
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}