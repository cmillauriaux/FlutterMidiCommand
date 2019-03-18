import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

const double _toleranceGoodHit = 0.15;
const double _toleranceAlmostHit = 0.3;

enum SongState {
  stop,
  starting,
  play,
  pause
}

class Tone {
  int time;
  bool isGood = false;
  bool isTooSoon = false;
  bool isTooLate = false;
  bool isMissed = false;
}

class Song {
  Map<String, List<Tone>> tracks = {};
  String title;
  int length;
  int speed;
  double tempo = -1;
  SongState state = SongState.stop;
  final Function(SongState) updateStatus;

  Song(this.updateStatus);

  static Future<Song> loadFromCSV(String name, Function updateStatus) async {
    Song song = Song(updateStatus);
    String s = await rootBundle.loadString(name);
    final res = const CsvToListConverter().convert(s, eol: "\n");
    if (res.length > 0 && res[0].length >= 2) {
      song.title = res[0][0];
      song.speed = res[0][1];
    }
    if (res.length > 1) {
      song.length = res[1].length;
      for (var i = 1; i < res.length; i++) {
        String track = "";
        List<Tone> tones = [];
        if (res[i].length > 0) {
          track = res[i][0];
          for (var j = 1; j < res[i].length; j++) {
            if (res[i][j] != '') {
              Tone t = Tone();
              t.time = j - 1;
              tones.add(t);
            }
          }
        }
        song.tracks[track] = tones;
      }
    }
    print(song);
    return song;
  }

  void start() {
    tracks.forEach((track, tones) {
      for (var tone in tones) {
        tone.isGood = false;
        tone.isMissed = false;
        tone.isTooLate = false;
        tone.isTooSoon = false;
      }
    });
    tempo = -1;
    state = SongState.starting;
  }

  void play() {
    tempo = 0;
    state = SongState.play;
    updateStatus(state);
  }

  void pause() {
    state = SongState.pause;
    updateStatus(state);
  }

  void resume() {
    state = SongState.play;
    updateStatus(state);
  }

  void stop() {
    state = SongState.stop;
    updateStatus(state);
  }

  void update(double dt) {
      tempo += dt;
      tracks.forEach((track, tones) {
        for (var tone in tones) {
          if (!tone.isGood && !tone.isTooLate && !tone.isTooSoon && speed / 60 * tempo > tone.time + _toleranceAlmostHit) {
            tone.isMissed = true;
          }
        }
      });
      if (speed / 60 * tempo >= length) {
        stop();
      }
  }

  hit(note) {
    String key = "";
    switch (note) {
      case 36:
        key =  "kick";
        break;
      case 38:
        key =  "snare";
        break;
      case 42:
        key =  "hiHat";
        break;
    }

    if (key != "" && tracks.containsKey(key)) {
      for (var tone in tracks[key]) {
        print(key);
        if (speed / 60 * tempo > tone.time - _toleranceGoodHit && speed / 60 * tempo < tone.time + _toleranceGoodHit) {
          tone.isGood = true;
          return;
        } else if (speed / 60 * tempo > tone.time - _toleranceAlmostHit && speed / 60 * tempo < tone.time) {
          tone.isTooSoon = true;
          return;
        } else if (speed / 60 * tempo > tone.time && speed / 60 * tempo < tone.time + _toleranceAlmostHit) {
          tone.isTooLate = true;
          return;
        }
      }
    }
  }
}