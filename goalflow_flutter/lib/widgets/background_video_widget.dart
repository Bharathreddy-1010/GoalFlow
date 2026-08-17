import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'bg_video_stub.dart' if (dart.library.html) 'bg_video_web.dart';

class BackgroundVideoWidget extends StatefulWidget {
  final String assetPath;
  final Widget fallbackWidget;
  final double zoomScale;

  const BackgroundVideoWidget({
    super.key,
    required this.assetPath,
    required this.fallbackWidget,
    this.zoomScale = 1.0,
  });

  @override
  State<BackgroundVideoWidget> createState() => _BackgroundVideoWidgetState();
}

class _BackgroundVideoWidgetState extends State<BackgroundVideoWidget> {
  VideoPlayerController? _controller;
  bool _isNativeInitialized = false;
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'goalflow-bg-video-${widget.assetPath.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')}';
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (kIsWeb) {
      registerWebVideoFactory(_viewId, widget.assetPath, widget.zoomScale);
      return;
    }

    try {
      _controller = VideoPlayerController.asset(widget.assetPath);
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      await _controller!.play();
      if (mounted) {
        setState(() {
          _isNativeInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('VideoPlayerController error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SizedBox.expand(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: widget.fallbackWidget,
              ),
              Positioned.fill(
                child: HtmlElementView(viewType: _viewId),
              ),
            ],
          ),
        ),
      );
    }

    if (_isNativeInitialized && _controller != null && _controller!.value.isInitialized) {
      return SizedBox.expand(
        child: ClipRect(
          child: Transform.scale(
            scale: widget.zoomScale,
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: widget.fallbackWidget,
    );
  }
}
