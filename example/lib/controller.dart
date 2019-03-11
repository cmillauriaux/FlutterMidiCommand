import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command_example/audio-sound-pool.dart';
import 'package:flutter_midi_command_example/drum.dart';
import 'package:flutter_midi_command_example/song.dart';
import 'package:flutter_midi_command_example/visual-drum.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:csv/csv.dart';

class ControllerPage extends StatelessWidget {
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
          ),
          body: MidiControls(),
          backgroundColor: Color(0xff616161),
        ));
  }
}

class MidiControls extends StatefulWidget {
  @override
  MidiControlsState createState() {
    return new MidiControlsState();
  }
}

class MidiControlsState extends State<MidiControls> {
  var _channel = 1;
  var _controller = 0;
  var _value = 0;

  StreamSubscription<List<int>> _rxSubscription;
  MidiCommand _midiCommand = MidiCommand();
  StreamController _noteStream = StreamController.broadcast();

  @override
  void initState() {
    _rxSubscription = _midiCommand.onMidiDataReceived.listen((data) {
      print('on data $data');
      var status = data[0];

      if (status == 0xF8) {
        print('beat');
        return;
      }

      if (data.length > 2) {
        var d1 = data[1];
        var d2 = data[2];
        if (d2 > 10) {
          _value = d1;
          _noteStream.add(d1);
        }
      }
    });
    //super.initState();
  }

  void dispose() {
    _rxSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MyWidget(_noteStream);
  }
}

class MyWidget extends StatefulWidget {
  StreamController controller;

  MyWidget(this.controller);

  @override
  MyWidgetState createState() => new MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  NodeWithSize rootNode;
  StreamSubscription _subscription;
  AudioDrum _drum = new AudioDrum();
  PlayDrum _visualDrum = new PlayDrum();

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
    _subscription = widget.controller.stream.listen((note) async {
      _visualDrum.hit(note);
      await _drum.play(note);
    });
    SpriteWidget sw =
        new SpriteWidget(rootNode, SpriteBoxTransformMode.scaleToFit);
    return sw;
  }
}