import 'package:flutter/material.dart';
import 'package:flutter_midi_command_example/models/song_summary.dart';
import 'package:flutter_midi_command_example/services/songs-library.dart';

class SongsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Songs List')
          ),
          body: FutureBuilder<List<SongSummary>>(
              future: SongsLibrary.list(),
              builder: (BuildContext context, AsyncSnapshot<List<SongSummary>> snapshot) {
                if (snapshot != null && snapshot.data != null) {
                  return ListView(
                    children: this.buildSongSummaryList(snapshot.data),
                  );
                } else {
                  return Text("Loading...");
                }
              }
          )
        ));
  }
  
  List<Widget> buildSongSummaryList(List<SongSummary> songs) {
    var list = List<Widget>();
    for (var song in songs) {
      list.add(ListTile(
          leading: Text("Lvl " + song.level.toString()),
          title: Text(song.title),
          subtitle: Text(song.type),
          onTap: () { /* react to the tile being tapped */ }
      ));
    }
    return list;
  }
}