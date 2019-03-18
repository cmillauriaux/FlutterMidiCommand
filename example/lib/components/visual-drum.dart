import 'dart:ui';

import 'package:spritewidget/spritewidget.dart';

class VisualDrum extends NodeWithSize {
  RedCircle _snare = new RedCircle(200, 720, 1400);
  RedCircle _tomA = new RedCircle(150, 550, 1080);
  RedCircle _tomB = new RedCircle(150, 890, 1080);
  RedCircle _smallCymbal = new RedCircle(75, 720, 880);
  RedCircle _hiHat = new RedCircle(175, 200, 1300);
  RedCircle _bigCymbal = new RedCircle(175, 1200, 1350);
  BalckRectangle _kick = new BalckRectangle(950, 1380, 1000, 1580);
  BalckRectangle _kickHiHat = new BalckRectangle(400, 1380, 450, 1580);

  VisualDrum({int note: 0}) : super(Size(1440.0, 2960.0)) {
    addChild(_snare);
    addChild(_tomA);
    addChild(_tomB);
    addChild(_smallCymbal);
    addChild(_kick);
    addChild(_kickHiHat);
    addChild(_hiHat);
    addChild(_bigCymbal);

    if (note > 0) {
      switch (note) {
        case 36:
          _snare.sleepColor = _snare.sleepColor.withAlpha(50);
          _tomA.sleepColor = _tomA.sleepColor.withAlpha(50);
          _tomB.sleepColor = _tomB.sleepColor.withAlpha(50);
          _smallCymbal.sleepColor = _smallCymbal.sleepColor.withAlpha(50);
          _hiHat.sleepColor = _hiHat.sleepColor.withAlpha(50);
          _bigCymbal.sleepColor = _bigCymbal.sleepColor.withAlpha(50);
          _kick.sleepColor = _kick.sleepColor.withAlpha(255);
          _kickHiHat.sleepColor = _kickHiHat.sleepColor.withAlpha(50);
          break;
        case 38:
          _snare.sleepColor = _snare.sleepColor.withAlpha(255);
          _tomA.sleepColor = _tomA.sleepColor.withAlpha(50);
          _tomB.sleepColor = _tomB.sleepColor.withAlpha(50);
          _smallCymbal.sleepColor = _smallCymbal.sleepColor.withAlpha(50);
          _hiHat.sleepColor = _hiHat.sleepColor.withAlpha(50);
          _bigCymbal.sleepColor = _bigCymbal.sleepColor.withAlpha(50);
          _kick.sleepColor = _kick.sleepColor.withAlpha(50);
          _kickHiHat.sleepColor = _kickHiHat.sleepColor.withAlpha(50);
          break;
        case 42:
          _snare.sleepColor = _snare.sleepColor.withAlpha(50);
          _tomA.sleepColor = _tomA.sleepColor.withAlpha(50);
          _tomB.sleepColor = _tomB.sleepColor.withAlpha(50);
          _smallCymbal.sleepColor = _smallCymbal.sleepColor.withAlpha(50);
          _hiHat.sleepColor = _hiHat.sleepColor.withAlpha(255);
          _bigCymbal.sleepColor = _bigCymbal.sleepColor.withAlpha(50);
          _kick.sleepColor = _kick.sleepColor.withAlpha(50);
          _kickHiHat.sleepColor = _kickHiHat.sleepColor.withAlpha(50);
          break;
      }
    }
  }

  hit(int note) {
    switch (note) {
      case 36:
        _kick.hit();
        break;
      case 38:
        _snare.hit();
        break;
      case 42:
        _hiHat.hit();
        break;
    }
  }
}

class DrumParts extends Node {
  double hitTime = 0;
  Color color = const Color(0xfff9a825);
  Color sleepColor = const Color(0xfff9a825);
  Color hitColor = const Color(0xffffd95a);

  @override
  void update(double dt) {
    if (hitTime > 0) {
      hitTime -= dt;
      color = hitColor;
    } else {
      color = sleepColor;
    }
  }

  void hit() {
    hitTime = 0.1;
  }
}

class RedCircle extends DrumParts {
  RedCircle(this.radius, this.x, this.y);

  double radius;
  double x;
  double y;

  @override
  void paint(Canvas canvas) {
    canvas.drawCircle(Offset(x, y), radius, new Paint()..color = color);
  }
}

class BalckRectangle extends DrumParts {
  BalckRectangle(this.left, this.top, this.right, this.bottom);
  double top;
  double left;
  double bottom;
  double right;

  @override
  void paint(Canvas canvas) {
    canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom), new Paint()..color = color);
  }
}