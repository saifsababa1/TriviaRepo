class WebAudioHelper {
  static dynamic createAudioElement(String src, bool loop, double volume) {
    return null;
  }

  static Future<void> play(dynamic audioElement) async {
    // No-op for non-web platforms
  }

  static void pause(dynamic audioElement) {
    // No-op for non-web platforms
  }

  static void setVolume(dynamic audioElement, double volume) {
    // No-op for non-web platforms
  }

  static void setCurrentTime(dynamic audioElement, double time) {
    // No-op for non-web platforms
  }
}
