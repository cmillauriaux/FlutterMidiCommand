import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command_example/audio-sound-pool.dart';
import 'package:flutter_midi_command_example/visual-drum.dart';
import 'package:spritewidget/spritewidget.dart';

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

class PlayDrum extends NodeWithSize {
  VisualDrum _hiHat = new VisualDrum(note: 42);
  VisualDrum _kick = new VisualDrum(note: 36);
  VisualDrum _snare = new VisualDrum(note: 38);
  MusicSheet _sheet = new MusicSheet(500, 500);

  PlayDrum() : super(Size(1440.0, 2960.0)) {
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
  Color color = const Color(0x55f9a825);
  Color tone = const Color(0xfff9a825);
  int length;
  int speed;
  static const double _totalPortion = 250.0;

  MusicSheet(this.length, this.speed) : super(Size(1440.0, 2960.0)) {}

  @override
  void paint(Canvas canvas) {
    canvas.drawRect(Rect.fromLTRB(0, 300, length * _totalPortion, 310),
        new Paint()..color = color);
    canvas.drawRect(Rect.fromLTRB(0, 800, length * _totalPortion, 810),
        new Paint()..color = color);
    canvas.drawRect(Rect.fromLTRB(0, 1300, length * _totalPortion, 1310),
        new Paint()..color = color);

    for (int i = 0; i < length; i++) {
      canvas.drawRect(
          Rect.fromLTRB(i * _totalPortion, 0, i * _totalPortion + 3, 3000),
          new Paint()..color = color);
    }

    for (int i = 0; i < length; i++) {
      canvas.drawRect(
          Rect.fromLTRB(
              i * _totalPortion - 30, 250, i * _totalPortion + 30, 350),
          new Paint()..color = tone);
      if (i % 4 == 0) {
        canvas.drawRect(
            Rect.fromLTRB(
                i * _totalPortion - 30, 750, i * _totalPortion + 30, 850),
            new Paint()..color = tone);
      }
      if (i % 4 == 2) {
        canvas.drawRect(
            Rect.fromLTRB(
                i * _totalPortion - 30, 1250, i * _totalPortion + 30, 1350),
            new Paint()..color = tone);
      }
    }
  }

  @override
  void update(double dt) {
    this.position = Offset(this.position.dx - dt * speed, this.position.dy);
  }
}
