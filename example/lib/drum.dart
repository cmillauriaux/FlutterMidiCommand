import 'dart:ui';

import 'package:flutter_midi_command_example/song.dart';
import 'package:flutter_midi_command_example/visual-drum.dart';
import 'package:spritewidget/spritewidget.dart';

class PlayDrum extends NodeWithSize {
  VisualDrum _hiHat = new VisualDrum(note: 42);
  VisualDrum _kick = new VisualDrum(note: 36);
  VisualDrum _snare = new VisualDrum(note: 38);
  PlayBar _playBar = new PlayBar();
  MusicSheet _sheet = new MusicSheet();

  PlayDrum() : super(Size(1440.0, 2960.0)) {
    _sheet.position = Offset(MusicSheet._totalPortion * 4 + 600, 0);
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
    _playBar.position = new Offset(600, 0);
    addChild(_playBar);
  }

  loadSong() async {
    Song s = await Song.loadFromCSV("assets/songs/simple.csv");
    _sheet.loadSong(s);
  }

  restartSong() {
    _sheet.position = Offset(MusicSheet._totalPortion * 4 + 600, 0);
    _sheet.restartSong();
  }

  hit(note) {
    _sheet.hit(note);
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

class PlayBar extends Node {
  Color lineColor = const Color(0xfff9a825);

  @override
  void paint(Canvas canvas) {
    canvas.drawRect(
        Rect.fromLTRB(0, 0, 10, 3000), new Paint()..color = lineColor);
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
  Color goodColor = const Color(0xff388e3c);
  Color almostColor = const Color(0xff303f9f);
  Color badColor = const Color(0xffd32f2f);
  Song song;
  double tempo = -1; 
  static const double _totalPortion = 250.0;
  static const double _toleranceGoodHit = 0.15;
  static const double _toleranceAlmostHit = 0.3;

  MusicSheet() : super(Size(1440.0, 2960.0)) {}

  loadSong(Song s) {
    this.song = s;
  }

  restartSong() {
    tempo = -1;
    song.tracks.forEach((track, tones) {
        for (var tone in tones) {
          tone.isGood = false;
          tone.isMissed = false;
          tone.isTooLate = false;
          tone.isTooSoon = false;
        }
    });
  }

  @override
  void paint(Canvas canvas) {
    if (song != null) {
      canvas.drawRect(Rect.fromLTRB(0, 275, song.length * _totalPortion, 280),
          new Paint()..color = lineColor);
      canvas.drawRect(Rect.fromLTRB(0, 775, song.length * _totalPortion, 780),
          new Paint()..color = lineColor);
      canvas.drawRect(Rect.fromLTRB(0, 1275, song.length * _totalPortion, 1280),
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
          Color color = toneColor;
          if (tone.isGood) {
            color = goodColor;
          } else if (tone.isTooLate || tone.isTooSoon) {
            color = almostColor;
          } else if (tone.isMissed) {
            color = badColor;
          }
          canvas.drawRect(
              Rect.fromLTRB(tone.time * _totalPortion - 30, posX,
                  tone.time * _totalPortion + 30, posX + 50),
              new Paint()..color = color);
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
      if (tempo == -1 && this.position.dx < 600) {
        tempo = 0;
      } else if (tempo >= 0) {
        tempo += dt;
        song.tracks.forEach((track, tones) {
        for (var tone in tones) {
          if (!tone.isGood && !tone.isTooLate && !tone.isTooSoon && song.speed / 60 * tempo > tone.time + _toleranceAlmostHit) {
            tone.isMissed = true;
          }
        }
        });
      }

      this.position = Offset(
          this.position.dx - (dt * song.speed * _totalPortion / 60),
          this.position.dy);
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
 
    if (key != "" && song.tracks.containsKey(key)) {
      for (var tone in song.tracks[key]) {
          print(key);
          if (song.speed / 60 * tempo > tone.time - _toleranceGoodHit && song.speed / 60 * tempo < tone.time + _toleranceGoodHit) {
            tone.isGood = true;
            return;
          } else if (song.speed / 60 * tempo > tone.time - _toleranceAlmostHit && song.speed / 60 * tempo < tone.time) {
            tone.isTooSoon = true;
            return;
          } else if (song.speed / 60 * tempo > tone.time && song.speed / 60 * tempo < tone.time + _toleranceAlmostHit) {
            tone.isTooLate = true;
            return;
          }
        }
    }
  }
}
