import 'package:flutter_midi_command_example/models/song_summary.dart';

class SongsLibrary {
  String type;
  int level;

  static Future<List<SongSummary>> list({type, level}) async {
    return [
      SongSummary(title: "Basic beat", type: "Rock", level: 1),
      SongSummary(title: "Basic beat", type: "Rock", level: 2),
      SongSummary(title: "Basic beat", type: "Rock", level: 3),
      SongSummary(title: "Basic beat", type: "Rock", level: 3),
      SongSummary(title: "Basic beat", type: "Funk", level: 1),
      SongSummary(title: "Basic beat", type: "Funk", level: 2),
      SongSummary(title: "Basic beat", type: "Funk", level: 3),
      SongSummary(title: "Basic beat", type: "Funk", level: 4),
      SongSummary(title: "Basic beat", type: "Dance", level: 1),
      SongSummary(title: "Basic beat", type: "Dance", level: 2),
      SongSummary(title: "Basic beat", type: "Dance", level: 3),
      SongSummary(title: "Basic beat", type: "Dance", level: 4)
    ];
  }
}