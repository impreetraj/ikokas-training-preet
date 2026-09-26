import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeVideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool isPlaying;

  const NativeVideoPlayerWidget({
    Key? key,
    required this.url,
    required this.isPlaying,
  }) : super(key: key);

  @override
  State<NativeVideoPlayerWidget> createState() => _NativeVideoPlayerWidgetState();
}

class _NativeVideoPlayerWidgetState extends State<NativeVideoPlayerWidget> {
  MethodChannel? _methodChannel;
  EventChannel? _eventChannel;
  bool _isBuffering = true;
  String? _errorMessage;

  @override
  void didUpdateWidget(NativeVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _methodChannel?.invokeMethod('play');
      } else {
        _methodChannel?.invokeMethod('pause');
      }
    }
  }

  void _onEvent(dynamic event) {
    final data = Map<String, dynamic>.from(event);
    switch (data['event']) {
      case 'buffering':
        if (mounted) setState(() { _isBuffering = true; _errorMessage = null; });
        break;
      case 'ready':
      case 'playing':
        if (mounted) setState(() { _isBuffering = false; _errorMessage = null; });
        break;
      case 'error':
        if (mounted) setState(() { _isBuffering = false; _errorMessage = data['message']; });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AndroidView(
          viewType: 'NativeVideoPlayerView',
          layoutDirection: TextDirection.ltr,
          creationParams: {'url': widget.url},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (int id) {
            _methodChannel = MethodChannel('com.example.reel_like/native_video_player_$id');
            _eventChannel = EventChannel('com.example.reel_like/native_video_player_events_$id');
            _eventChannel?.receiveBroadcastStream().listen(_onEvent);
            
            if (widget.isPlaying) {
              _methodChannel?.invokeMethod('play');
            }
          },
        ),
        
     
        
        if (_errorMessage != null)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () {
                    setState(() { _isBuffering = true; _errorMessage = null; });
                    _methodChannel?.invokeMethod('retry');
                  },
                  child: const Text("Retry"),
                )
              ],
            ),    
          )
      ],
    );
  }
}
