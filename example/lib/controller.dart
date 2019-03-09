import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:synchronized/synchronized.dart';
import 'package:soundpool/soundpool.dart';
import 'dart:math' as math;

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
  StreamController _noteStream = StreamController();

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
        _value = d1;
        _noteStream.add(d1);
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

  @override
  void initState() {
    super.initState();
    rootNode = new NodeWithSize(const Size(1024.0, 1024.0));
  }

  @override
  Widget build(BuildContext context) {
    _drum.load();
    _subscription = widget.controller.stream.listen((note) async {
      await _drum.play(note);
    });
    return new SpriteWidget(rootNode);
  }
}

class AudioDrum {
  Soundpool _hiHatpool = Soundpool(streamType: StreamType.music);
  Soundpool _hiHatpool2 = Soundpool(streamType: StreamType.music);
  Soundpool _hiHatpool3 = Soundpool(streamType: StreamType.music);
  Soundpool _kickpool = Soundpool(streamType: StreamType.music);
  Soundpool _snarepool = Soundpool(streamType: StreamType.music);
  int _hiHatSound;
  int _hiHatSound2;
  int _hiHatSound3;
  int _kickSound;
  int _snareSound;
  int _hiHatCount = 0;

  load() async {
    //await _hiHat.init();
    //await _snare.init();
    _kickSound = await rootBundle
        .load("assets/audio/sfx/kick.mp3")
        .then((ByteData soundData) {
      return _kickpool.load(soundData);
    });
    _hiHatSound = await rootBundle
        .load("assets/audio/sfx/snare.mp3")
        .then((ByteData soundData) {
      return _hiHatpool.load(soundData);
    });
    _hiHatSound2 = await rootBundle
        .load("assets/audio/sfx/snare.mp3")
        .then((ByteData soundData) {
      return _hiHatpool2.load(soundData);
    });
    _hiHatSound3 = await rootBundle
        .load("assets/audio/sfx/snare.mp3")
        .then((ByteData soundData) {
      return _hiHatpool3.load(soundData);
    });
    _snareSound = await rootBundle
        .load("assets/audio/sfx/hihat.mp3")
        .then((ByteData soundData) {
      return _snarepool.load(soundData);
    });
    //soundId = await pool.loadUri("https://github.com/ukasz123/soundpool/raw/master/example/sounds/dices.m4a");
  }

  play(note) async {
    print(note);
    switch (note) {
      case 36:
        await _kickpool.play(_kickSound);
        /*await _hiHat.start('kick.mp3');
        await _hiHat.start('hihat.mp3');
        await _hiHat.start('snare.mp3');*/
        //_hiHat.stop();
        break;
      case 38:
        _hiHatCount = (_hiHatCount + 1) % 3;
        switch (_hiHatCount) {
          case 0: 
            await _hiHatpool.play(_hiHatSound);
            break;
          case 1: 
            await _hiHatpool2.play(_hiHatSound2);
            break;
          case 2: 
            await _hiHatpool3.play(_hiHatSound3);
            break;
        }
        
        /*await _hiHat.start('kick.mp3');
        await _hiHat.start('hihat.mp3');
        await _hiHat.start('snare.mp3');*/
        //_hiHat.stop();
        break;
      case 42:
        await _snarepool.play(_snareSound);
        /*await _hiHat.start('kick.mp3');
        await _hiHat.start('hihat.mp3');
        await _hiHat.start('snare.mp3');*/
        break;
    }
  }
}
