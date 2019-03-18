import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command_example/components/drum.dart';
import 'package:flutter_midi_command_example/models/audio-sound-pool.dart';
import 'package:flutter_midi_command_example/models/song.dart';
import 'package:flutter_midi_command_example/pages/song_result.dart';
import 'package:spritewidget/spritewidget.dart';

class PlayDrumPage extends StatelessWidget {
  final StreamController _restartStream = StreamController();

  Future<bool> _save() {
    print('close disconnect');
    MidiCommand().disconnectDevice();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _save,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Controls'),
            actions: <Widget>[
              IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _restartStream.add("");
              },
            ),
            ],
          ),
          body: MidiControls(_restartStream.stream),
          backgroundColor: Color(0xff616161),
        ));
  }
}

class MidiControls extends StatefulWidget {
  final Stream _onRestartConsumer;
  MidiControls(this._onRestartConsumer);
  
  @override
  MidiControlsState createState() {
    return new MidiControlsState();
  }
}

class MidiControlsState extends State<MidiControls> {
  MidiControlsState();

  StreamSubscription<List<int>> _rxSubscription;
  MidiCommand _midiCommand = MidiCommand();
  StreamController _noteStream = StreamController.broadcast();

  @override
  void initState() {
    _rxSubscription = _midiCommand.onMidiDataReceived.listen((data) {
      var status = data[0];

      if (status == 0xF8) {
        print('beat');
        return;
      }

      if (data.length > 2) {
        var d1 = data[1];
        var d2 = data[2];
        if (d2 > 10) {
          _noteStream.add(d1);
        }
      }
    });
    super.initState();
  }

  void dispose() {
    _rxSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MyWidget(_noteStream, widget._onRestartConsumer);
  }
}

class MyWidget extends StatefulWidget {
  final StreamController controller;
  final Stream _onRestartConsumer;

  MyWidget(this.controller, this._onRestartConsumer);

  @override
  MyWidgetState createState() => new MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  NodeWithSize rootNode;
  StreamSubscription _subscription;
  AudioDrum _drum = new AudioDrum();
  PlayDrum _visualDrum;
  StreamSubscription _onRestartSubscription;

  MyWidgetState() {
    _visualDrum = new PlayDrum(updateStatus);
  }

  @override
  void initState() {
    super.initState();
    rootNode = new NodeWithSize(const Size(1440.0, 2960.0));
    rootNode.addChild(_visualDrum);
    _visualDrum.loadSong();
  }

  @override
  Widget build(BuildContext context) {
    _drum.load();
    _onRestartSubscription = widget._onRestartConsumer.listen((data) {
      _visualDrum.restartSong();
    });
    _subscription = widget.controller.stream.listen((note) async {
      _visualDrum.hit(note);
      await _drum.play(note);
    });
    SpriteWidget sw =
        new SpriteWidget(rootNode, SpriteBoxTransformMode.scaleToFit);
    return sw;
  }

  void dispose() {
    _subscription.cancel();
    _onRestartSubscription.cancel();
    super.dispose();
  }

  void updateStatus(SongState status) {
    if (status == SongState.stop) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SongResultPage(_visualDrum.song)));
    }
  }
}