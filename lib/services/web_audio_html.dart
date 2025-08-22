import 'dart:html' as html;

class WebAudioHelper {
  static dynamic createAudioElement(String src, bool loop, double volume) {
    final audio =
        html.AudioElement()
          ..src = src
          ..loop = loop
          ..volume = volume;
    return audio;
  }

  static Future<void> play(dynamic audioElement) async {
    if (audioElement is html.AudioElement) {
      await audioElement.play();
    }
  }

  static void pause(dynamic audioElement) {
    if (audioElement is html.AudioElement) {
      audioElement.pause();
    }
  }

  static void setVolume(dynamic audioElement, double volume) {
    if (audioElement is html.AudioElement) {
      audioElement.volume = volume;
    }
  }

  static void setCurrentTime(dynamic audioElement, double time) {
    if (audioElement is html.AudioElement) {
      audioElement.currentTime = time;
    }
  }
}
