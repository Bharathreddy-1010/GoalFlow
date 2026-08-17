// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

void registerWebVideoFactory(String viewId, String assetPath, double zoomScale) {
  try {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final video = html.VideoElement()
        ..autoplay = true
        ..loop = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..setAttribute('muted', 'true')
        ..setAttribute('autoplay', 'true')
        ..setAttribute('loop', 'true')
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = 'scale($zoomScale)'
        ..style.transformOrigin = 'top left'
        ..style.filter = 'brightness(1.25) contrast(1.10) saturate(1.12)'
        ..style.border = 'none'
        ..style.pointerEvents = 'none'
        ..src = 'assets/$assetPath';

      video.onError.listen((_) {
        video.src = assetPath;
        video.play();
      });

      video.play().catchError((err) {
        debugPrint('Video play note: $err');
      });

      return video;
    });
  } catch (e) {
    debugPrint('registerViewFactory note: $e');
  }
}
