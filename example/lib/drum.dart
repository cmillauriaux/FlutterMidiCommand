
import 'dart:ui';

import 'package:flutter_midi_command_example/song.dart';
import 'package:flutter_midi_command_example/visual-drum.dart';
import 'package:spritewidget/spritewidget.dart';

class PlayDrum extends NodeWithSize {
  VisualDrum _hiHat = new VisualDrum(note: 42);
  VisualDrum _kick = new VisualDrum(note: 36);
  VisualDrum _snare = new VisualDrum(note: 38);
  MusicSheet _sheet = new MusicSheet();

  PlayDrum() : super(Size(1440.0, 2960.0)) {
    _sheet.position = Offset(1500, 0);
    addChild(_sheet);
    addChild(Background());
    _hiHat.scale = 0.25;
    _hiHat.position = new Offset(-100, 0);
    addChild(_hiHat);
    _kick.scale = 0.25;
    _kick.position = new Offset(-100, 500);
    addChild(_kick);
    _snare.scale = 0.25;
    _snare.position = new Offset(-100, 1000);
    addChild(_snare);
  }

  loadSong() async {
    Song s = await Song.loadFromCSV("assets/songs/simple.csv");
    _sheet.loadSong(s);
  }

  hit(note) {
    switch (note) {
      case 36:
        _kick.hit(36);
        break;
      case 38:
        _snare.hit(38);
        break;
      case 42:
        _hiHat.hit(42);
        break;
    }
  }
}

class Background extends Node {
  @override
  void paint(Canvas canvas) {
    canvas.drawRect(Rect.fromLTRB(-150, 0, 300, 3000),
        new Paint()..color = Color(0xff494949));
  }
}

class MusicSheet extends NodeWithSize {
  Color lineColor = const Color(0x55f9a825);
  Color toneColor = const Color(0xfff9a825);
  Song song;
  static const double _totalPortion = 250.0;

  MusicSheet() : super(Size(1440.0, 2960.0)) {}

  loadSong(Song s) {
    this.song = s;
  }

  @override
  void paint(Canvas canvas) {
    if (song != null) {
      canvas.drawRect(Rect.fromLTRB(0, 300, song.length * _totalPortion, 310),
          new Paint()..color = lineColor);
      canvas.drawRect(Rect.fromLTRB(0, 800, song.length * _totalPortion, 810),
          new Paint()..color = lineColor);
      canvas.drawRect(Rect.fromLTRB(0, 1300, song.length * _totalPortion, 1310),
          new Paint()..color = lineColor);

      song.tracks.forEach((track, tones) {
        double posX = 0;
        switch (track) {
          case 'hiHat':
            posX = 250;
            break;
          case 'kick':
            posX = 750;
            break;
          case 'snare':
            posX = 1250;
            break;
          default:
        }
        for (var tone in tones) {
          canvas.drawRect(
              Rect.fromLTRB(tone.time * _totalPortion - 30, posX,
                  tone.time * _totalPortion + 30, posX + 50),
              new Paint()..color = toneColor);
        }
      });

      for (int i = 0; i < song.length; i++) {
        canvas.drawRect(
            Rect.fromLTRB(i * _totalPortion, 0, i * _totalPortion + 3, 3000),
            new Paint()..color = lineColor);
      }
    }
  }

  @override
  void update(double dt) {
    if (song != null) {
      this.position =
        Offset(this.position.dx - dt * song.speed, this.position.dy);
    }
  }
}
