import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum PlayerState { loading, playing, paused }

class PlayerModel extends ChangeNotifier {
  AudioPlayer? player;
  Duration total = Duration.zero;
  Duration buffered = Duration.zero;
  StreamSubscription<Duration>? bufferedStreamSub;
  Duration current = Duration.zero;
  StreamSubscription<Duration>? currentStreamSub;
  PlayerState state = PlayerState.loading;
  StreamSubscription? stateStreamSub;

  set url(String url) {
    _init(url);
  }

  Future<void> _init(String url) async {
    player = AudioPlayer();
    await player!.setUrl(url);
    total = player!.duration!;

    stateStreamSub = player!.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        state = PlayerState.loading;
      } else if (!playerState.playing) {
        state = PlayerState.paused;
      } else if (processingState != ProcessingState.completed) {
        state = PlayerState.playing;
      } else {
        player!.seek(Duration.zero);
        player!.pause();
        state = PlayerState.paused;
      }
      notifyListeners();
    });

    bufferedStreamSub = player!.bufferedPositionStream.listen((position) {
      buffered = position;
      notifyListeners();
    });

    currentStreamSub = player!.positionStream.listen((position) {
      current = position;
      notifyListeners();
    });

    player!.play();
    notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {
    player!.dispose();
    total = Duration.zero;
    buffered = Duration.zero;
    bufferedStreamSub = null;
    current = Duration.zero;
    currentStreamSub = null;
    state = PlayerState.loading;
    stateStreamSub = null;
  }
}
