// Non-web stub for web audio helper.
// On non-web platforms, audio is played via audioplayers in the widget layer.

class WebAudioHelper {
  /// No-op on non-web platforms.
  static void play(String assetPath) {}

  /// Always false on non-web platforms.
  static bool get isWeb => false;
}
