import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

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

  static Future<Song> loadFromCSV(String name) async {
    Song song = Song();
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
}