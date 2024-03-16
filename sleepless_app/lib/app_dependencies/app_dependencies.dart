import 'package:flutter/widgets.dart' as widgets;
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

final class AppDependencies {
  final String stub;
  final AudioPlayer player;

  AppDependencies({
    required this.stub,
    required this.player,
  });
}

extension AppDependenciesGetter on widgets.BuildContext {
  AppDependencies appDependencies() => Provider.of<AppDependencies>(this, listen: false);
}
