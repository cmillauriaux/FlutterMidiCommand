import 'package:flutter/material.dart';
import 'package:flutter_midi_command_example/models/song.dart';

class SongResultPage extends StatelessWidget {
  final Song _song;

  const SongResultPage(this._song, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
              title: Text('Songs List')
          ),
          body: Row(
            children: <Widget>[],
          ),
        ));
  }
}