import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Web-specific imports
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class SmashWallsWeb {
  static void initializeWebIframe() {
    if (kIsWeb) {
      // Register the platform view factory for web
      ui_web.platformViewRegistry.registerViewFactory(
        'smash-walls-iframe',
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = 'https://smashthewalls.com/'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'autoplay; fullscreen; microphone; camera'
            ..allowFullscreen = true;

          return iframe;
        },
      );
    }
  }

  static Widget buildWebIframe() {
    if (kIsWeb) {
      return const HtmlElementView(
        viewType: 'smash-walls-iframe',
      );
    } else {
      return const Center(
        child: Text(
          'Web iframe not available on this platform',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}

