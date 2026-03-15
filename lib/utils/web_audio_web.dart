import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web-specific audio helper using native HTMLAudioElement.
/// Bypasses audioplayers' path resolution issues on deployed Flutter web apps.
class WebAudioHelper {
  /// Plays an asset sound file using native browser Audio API.
  /// [assetPath] should be like 'assets/sounds/celebration.mp3'
  /// (relative to web root; Flutter build places it at assets/assets/sounds/...).
  static void play(String assetPath) {
    // On deployed Flutter web, assets are at <base-href>/assets/<assetPath>
    final audio = web.HTMLAudioElement()..src = 'assets/$assetPath';
    audio.play().toDart.catchError((_) => null);
  }

  /// True on web platforms.
  static bool get isWeb => true;
}
