import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class AudioPool {
  int id;
  Soundpool pool;

  AudioPool(this.id, this.pool);
}

class AudioSoundPool {
  Map<String, List<AudioPool>> pool = {};

  int _size;
  int _current = 0;

  AudioSoundPool({int size = 3}) {
    _size = size;
  }

  register(String name, {prefix: "assets/audio/sfx/"}) async {
    List<AudioPool> p = [];
    for (var i = 0; i < _size; i++) {
      Soundpool sp = Soundpool(streamType: StreamType.music);
      var id = await rootBundle
          .load(prefix + name)
          .then((ByteData soundData) {
        return sp.load(soundData);
      });
      p.add(AudioPool(id, sp));
    }
    pool[name] = p;
  }

  play(String name) {
    if (pool.containsKey(name)) {
      var rnd = (_current ++) % pool[name].length;
      pool[name][rnd].pool.play(pool[name][rnd].id);
    }
  }
}

class AudioDrum {
  AudioSoundPool _pool =AudioSoundPool();

  load() async {
    await _pool.register("kick.mp3");
    await _pool.register("snare.mp3");
    await _pool.register("hihat.mp3");
  }

  play(note) async {
    print(note);
    switch (note) {
      case 36:
        _pool.play("kick.mp3");
        break;
      case 38:
        _pool.play("snare.mp3");
        break;
      case 42:
        _pool.play("hihat.mp3");
        break;
    }
  }
}