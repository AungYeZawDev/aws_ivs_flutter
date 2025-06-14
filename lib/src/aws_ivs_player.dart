import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// AWS IVS Player class for handling video streaming operations
class AwsIvsPlayer {
  static const MethodChannel _channel = MethodChannel('aws_ivs_flutter');
  static const String viewType = 'aws_ivs_player_view';
  
  /// Create player with stream URL
  static Future<String?> createPlayer(String streamUrl) async {
    try {
      final result = await _channel.invokeMethod('createPlayer', {
        'streamUrl': streamUrl,
      });
      return result as String?;
    } catch (e) {
      debugPrint('Error creating player: $e');
      return null;
    }
  }
  
  /// Start playback
  static Future<String?> play() async {
    try {
      final result = await _channel.invokeMethod('play');
      return result as String?;
    } catch (e) {
      debugPrint('Error starting playback: $e');
      return null;
    }
  }
  
  /// Pause playback
  static Future<String?> pause() async {
    try {
      final result = await _channel.invokeMethod('pause');
      return result as String?;
    } catch (e) {
      debugPrint('Error pausing playback: $e');
      return null;
    }
  }
  
  /// Stop playback
  static Future<String?> stop() async {
    try {
      final result = await _channel.invokeMethod('stop');
      return result as String?;
    } catch (e) {
      debugPrint('Error stopping playback: $e');
      return null;
    }
  }
  
  /// Load new stream URL
  static Future<String?> loadStream(String streamUrl) async {
    try {
      final result = await _channel.invokeMethod('loadStream', {
        'streamUrl': streamUrl,
      });
      return result as String?;
    } catch (e) {
      debugPrint('Error loading stream: $e');
      return null;
    }
  }
  
  /// Set volume (0.0 to 1.0)
  static Future<String?> setVolume(double volume) async {
    try {
      final result = await _channel.invokeMethod('setVolume', {
        'volume': volume.clamp(0.0, 1.0),
      });
      return result as String?;
    } catch (e) {
      debugPrint('Error setting volume: $e');
      return null;
    }
  }
  
  /// Get current player state
  static Future<String?> getPlayerState() async {
    try {
      final result = await _channel.invokeMethod('getPlayerState');
      return result as String?;
    } catch (e) {
      debugPrint('Error getting player state: $e');
      return null;
    }
  }
  
  /// Get video duration in milliseconds
  static Future<int?> getDuration() async {
    try {
      final result = await _channel.invokeMethod('getDuration');
      return result as int?;
    } catch (e) {
      debugPrint('Error getting duration: $e');
      return null;
    }
  }
  
  /// Get current playback position in milliseconds
  static Future<int?> getPosition() async {
    try {
      final result = await _channel.invokeMethod('getPosition');
      return result as int?;
    } catch (e) {
      debugPrint('Error getting position: $e');
      return null;
    }
  }
  
  /// Seek to position in milliseconds
  static Future<String?> seekTo(int positionMs) async {
    try {
      final result = await _channel.invokeMethod('seekTo', {
        'position': positionMs,
      });
      return result as String?;
    } catch (e) {
      debugPrint('Error seeking: $e');
      return null;
    }
  }
  
  /// Dispose player and free resources
  static Future<String?> dispose() async {
    try {
      final result = await _channel.invokeMethod('dispose');
      return result as String?;
    } catch (e) {
      debugPrint('Error disposing player: $e');
      return null;
    }
  }
  
  /// Get platform version
  static Future<String?> getPlatformVersion() async {
    try {
      final result = await _channel.invokeMethod('getPlatformVersion');
      return result as String?;
    } catch (e) {
      debugPrint('Error getting platform version: $e');
      return null;
    }
  }
}