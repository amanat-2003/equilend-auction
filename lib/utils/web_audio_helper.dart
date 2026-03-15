// Conditional-import barrel that routes to the correct platform implementation.
//
// On web → web_audio_web.dart (native HTMLAudioElement)
// On non-web → web_audio_stub.dart (no-op; audioplayers handles it)
export 'web_audio_stub.dart'
    if (dart.library.js_interop) 'web_audio_web.dart';
