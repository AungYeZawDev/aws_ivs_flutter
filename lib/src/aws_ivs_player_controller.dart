import 'dart:async';
import 'package:aws_ivs_flutter/aws_ivs_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Controller for managing AWS IVS Player operations
class AwsIvsPlayerController {
  bool _isInitialized = false;
  String? _currentStreamUrl;
  
  /// Whether the player has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Current stream URL
  String? get currentStreamUrl => _currentStreamUrl;

  /// Initialize the player with a stream URL
  Future<void> initialize(String streamUrl) async {
    if (_isInitialized) {
      await dispose();
    }
    
    final result = await AwsIvsPlayer.createPlayer(streamUrl);
    if (result != null) {
      _isInitialized = true;
      _currentStreamUrl = streamUrl;
    } else {
      throw Exception('Failed to initialize player');
    }
  }

  /// Load a new stream URL
  Future<void> loadStream(String streamUrl) async {
    if (!_isInitialized) {
      throw Exception('Player not initialized. Call initialize() first.');
    }
    
    final result = await AwsIvsPlayer.loadStream(streamUrl);
    if (result != null) {
      _currentStreamUrl = streamUrl;
    } else {
      throw Exception('Failed to load stream');
    }
  }

  /// Start playback
  Future<void> play() async {
    if (!_isInitialized) {
      throw Exception('Player not initialized. Call initialize() first.');
    }
    
    final result = await AwsIvsPlayer.play();
    if (result == null) {
      throw Exception('Failed to start playback');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    if (!_isInitialized) {
      throw Exception('Player not initialized. Call initialize() first.');
    }
    
    final result = await AwsIvsPlayer.pause();
    if (result == null) {
      throw Exception('Failed to pause playback');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    if (!_isInitialized) {
      throw Exception('Player not initialized. Call initialize() first.');
    }
    
    final result = await AwsIvsPlayer.stop();
    if (result == null) {
      throw Exception('Failed to stop playback');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) {
      throw Exception('Player not initialized. Call initialize() first.');
    }
    
    final result = await AwsIvsPlayer.setVolume(volume);
    if (result == null) {
      throw Exception('Failed to set volume');
    }
  }

  /// Get current player state
  Future<String?> getPlayerState() async {
    if (!_isInitialized) {
      return null;
    }
    
    return await AwsIvsPlayer.getPlayerState();
  }

  /// Get video duration in milliseconds
  Future<int?> getDuration() async {
    if (!_isInitialized) {
      return null;
    }
    
    return await AwsIvsPlayer.getDuration();
  }

  /// Get current playback position in milliseconds
  Future<int?> getPosition() async {
    if (!_isInitialized) {
      return null;
    }
    
    return await AwsIvsPlayer.getPosition();
  }

  /// Seek to position in milliseconds
  Future<void> seekTo(int positionMs) async {
    if (!_isInitialized) {
      throw Exception('Player not initialized. Call initialize() first.');
    }
    
    final result = await AwsIvsPlayer.seekTo(positionMs);
    if (result == null) {
      throw Exception('Failed to seek to position');
    }
  }

  /// Check if player is currently playing
  Future<bool> isPlaying() async {
    final state = await getPlayerState();
    return state == 'PLAYING';
  }

  /// Check if player is currently paused
  Future<bool> isPaused() async {
    final state = await getPlayerState();
    return state == 'READY' || state == 'IDLE';
  }

  /// Check if player is buffering
  Future<bool> isBuffering() async {
    final state = await getPlayerState();
    return state == 'BUFFERING';
  }

  /// Check if playback has ended
  Future<bool> hasEnded() async {
    final state = await getPlayerState();
    return state == 'ENDED';
  }

  /// Get playback progress as a percentage (0.0 to 1.0)
  Future<double> getProgress() async {
    final position = await getPosition();
    final duration = await getDuration();
    
    if (position == null || duration == null || duration == 0) {
      return 0.0;
    }
    
    return (position / duration).clamp(0.0, 1.0);
  }

  /// Seek to a percentage of the video duration (0.0 to 1.0)
  Future<void> seekToPercentage(double percentage) async {
    final duration = await getDuration();
    if (duration != null) {
      final position = (duration * percentage.clamp(0.0, 1.0)).round();
      await seekTo(position);
    }
  }

  /// Dispose the player and free resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await AwsIvsPlayer.dispose();
      _isInitialized = false;
      _currentStreamUrl = null;
    }
  }

  /// Create a value notifier for player state changes
  ValueNotifier<String> createStateNotifier() {
    final notifier = ValueNotifier<String>('IDLE');
    
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }
      
      final state = await getPlayerState();
      if (state != null && state != notifier.value) {
        notifier.value = state;
      }
    });
    
    return notifier;
  }

  /// Create a value notifier for playback position
  ValueNotifier<Duration> createPositionNotifier() {
    final notifier = ValueNotifier<Duration>(Duration.zero);
    
    Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }
      
      final position = await getPosition();
      if (position != null) {
        notifier.value = Duration(milliseconds: position);
      }
    });
    
    return notifier;
  }

  /// Create a value notifier for video duration
  ValueNotifier<Duration> createDurationNotifier() {
    final notifier = ValueNotifier<Duration>(Duration.zero);
    
    Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }
      
      final duration = await getDuration();
      if (duration != null) {
        notifier.value = Duration(milliseconds: duration);
      }
    });
    
    return notifier;
  }
}
