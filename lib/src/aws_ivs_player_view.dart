
import 'dart:async';
import 'dart:io';
import 'package:aws_ivs_flutter/aws_ivs_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// AWS IVS Player View widget that displays the video stream
class AwsIvsPlayerView extends StatefulWidget {
  /// Stream URL to play
  final String streamUrl;
  
  /// Player controller for managing playback
  final AwsIvsPlayerController? controller;
  
  /// Callback when player is ready
  final VoidCallback? onReady;
  
  /// Callback when player state changes
  final Function(String state)? onStateChanged;
  
  /// Callback when an error occurs
  final Function(String error)? onError;
  
  /// Whether to show default controls
  final bool showControls;
  
  /// Aspect ratio for the video player
  final double? aspectRatio;
  
  /// Background color when no video is playing
  final Color backgroundColor;

  const AwsIvsPlayerView({
    super.key,
    required this.streamUrl,
    this.controller,
    this.onReady,
    this.onStateChanged,
    this.onError,
    this.showControls = true,
    this.aspectRatio,
    this.backgroundColor = Colors.black,
  });

  @override
  State<AwsIvsPlayerView> createState() => _AwsIvsPlayerViewState();
}

class _AwsIvsPlayerViewState extends State<AwsIvsPlayerView> {
  AwsIvsPlayerController? _controller;
  bool _isInitialized = false;
  String _currentState = 'IDLE';
  Timer? _stateTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AwsIvsPlayerController();
    _initializePlayer();
    _startStatePolling();
  }

  @override
  void didUpdateWidget(AwsIvsPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _loadNewStream();
    }
  }

  @override
  void dispose() {
    _stateTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      await _controller!.initialize(widget.streamUrl);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        widget.onReady?.call();
      }
    } catch (e) {
      widget.onError?.call('Failed to initialize player: $e');
    }
  }

  Future<void> _loadNewStream() async {
    try {
      await _controller!.loadStream(widget.streamUrl);
    } catch (e) {
      widget.onError?.call('Failed to load stream: $e');
    }
  }

  void _startStatePolling() {
    _stateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_controller != null && _isInitialized) {
        final state = await _controller!.getPlayerState();
        if (state != null && state != _currentState && mounted) {
          setState(() {
            _currentState = state;
          });
          widget.onStateChanged?.call(state);
        }
      }
    });
  }

  Widget _buildPlatformView() {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: AwsIvsPlayer.viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: AwsIvsPlayer.viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: {'streamUrl': widget.streamUrl},
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          );
        },
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: AwsIvsPlayer.viewType,
        creationParams: {'streamUrl': widget.streamUrl},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    
    return Container(
      color: widget.backgroundColor,
      child: const Center(
        child: Text(
          'Platform not supported',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (!widget.showControls || !_isInitialized) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _controller!.play,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
            ),
            IconButton(
              onPressed: _controller!.pause,
              icon: const Icon(Icons.pause, color: Colors.white),
            ),
            IconButton(
              onPressed: _controller!.stop,
              icon: const Icon(Icons.stop, color: Colors.white),
            ),
            Expanded(
              child: Slider(
                value: 0.5,
                onChanged: (value) => _controller!.setVolume(value),
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              ),
            ),
            Text(
              _currentState,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (_currentState == 'BUFFERING' || !_isInitialized) {
      return const Positioned.fill(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = _buildPlatformView();

    if (widget.aspectRatio != null) {
      child = AspectRatio(
        aspectRatio: widget.aspectRatio!,
        child: child,
      );
    }

    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          child,
          _buildLoadingIndicator(),
          _buildControls(),
        ],
      ),
    );
  }
}
