# AWS IVS Flutter Plugin

A comprehensive Flutter plugin for AWS Interactive Video Service (IVS) that provides live video streaming capabilities for both Android and iOS platforms.

## Features

- ✅ Live video streaming with AWS IVS Player SDK v1.41.0
- ✅ Cross-platform support (Android & iOS)
- ✅ Platform views for embedded video display
- ✅ Comprehensive playback controls (play, pause, stop, seek)
- ✅ Volume control and quality selection
- ✅ Real-time player state monitoring
- ✅ Error handling and logging
- ✅ Stream URL loading with parameter support

## Requirements

### Android
- Android API level 21 (Android 5.0) or higher
- Kotlin 1.8.0+
- Android Gradle Plugin 8.0.0+

### iOS
- iOS 12.0 or higher
- Swift 5.0+
- Xcode 12.0+

## Installation

### 1. Add Plugin to Flutter Project

Add this plugin to your Flutter project by copying the plugin files to your project structure:

```
your_flutter_project/
├── plugins/
│   └── aws_ivs_flutter/
│       ├── android/
│       ├── ios/
│       └── README.md
```

### 2. Add Dependency in pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  aws_ivs_flutter:
    path: ./plugins/aws_ivs_flutter
```

### 3. Android Setup

#### Add to android/app/build.gradle:
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 21
        targetSdk 34
    }
}

dependencies {
    implementation 'com.amazonaws:ivs-player:1.41.0'
}
```

#### Add permissions in android/app/src/main/AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 4. iOS Setup

#### Add to ios/Podfile:
```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # AWS IVS Player SDK
  pod 'AmazonIVSPlayer', '~> 1.41.0'
end
```

#### Update iOS deployment target:
In Xcode, set the deployment target to iOS 12.0 or higher.

#### Add network permissions in ios/Runner/Info.plist:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Usage

### 1. Import the Plugin

```dart
import 'package:flutter/services.dart';
```

### 2. Initialize Method Channel

```dart
class AwsIvsPlayer {
  static const MethodChannel _channel = MethodChannel('aws_ivs_flutter');
  
  // Platform view for video display
  static const String viewType = 'aws_ivs_player_view';
}
```

### 3. Basic Implementation

```dart
class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  
  const VideoPlayerScreen({Key? key, required this.streamUrl}) : super(key: key);
  
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    try {
      await AwsIvsPlayer.createPlayer(widget.streamUrl);
      await AwsIvsPlayer.play();
    } catch (e) {
      print('Error initializing player: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AWS IVS Player')),
      body: Column(
        children: [
          // Video player view
          Container(
            height: 200,
            child: _buildPlayerView(),
          ),
          // Controls
          _buildControls(),
        ],
      ),
    );
  }
  
  Widget _buildPlayerView() {
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
  }
  
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => AwsIvsPlayer.play(),
          child: Text('Play'),
        ),
        ElevatedButton(
          onPressed: () => AwsIvsPlayer.pause(),
          child: Text('Pause'),
        ),
        ElevatedButton(
          onPressed: () => AwsIvsPlayer.stop(),
          child: Text('Stop'),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    AwsIvsPlayer.dispose();
    super.dispose();
  }
}
```

### 4. Complete AwsIvsPlayer Class

```dart
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
      print('Error creating player: $e');
      return null;
    }
  }
  
  /// Start playback
  static Future<String?> play() async {
    try {
      final result = await _channel.invokeMethod('play');
      return result as String?;
    } catch (e) {
      print('Error starting playback: $e');
      return null;
    }
  }
  
  /// Pause playback
  static Future<String?> pause() async {
    try {
      final result = await _channel.invokeMethod('pause');
      return result as String?;
    } catch (e) {
      print('Error pausing playback: $e');
      return null;
    }
  }
  
  /// Stop playback
  static Future<String?> stop() async {
    try {
      final result = await _channel.invokeMethod('stop');
      return result as String?;
    } catch (e) {
      print('Error stopping playback: $e');
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
      print('Error loading stream: $e');
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
      print('Error setting volume: $e');
      return null;
    }
  }
  
  /// Get current player state
  static Future<String?> getPlayerState() async {
    try {
      final result = await _channel.invokeMethod('getPlayerState');
      return result as String?;
    } catch (e) {
      print('Error getting player state: $e');
      return null;
    }
  }
  
  /// Get video duration in milliseconds
  static Future<int?> getDuration() async {
    try {
      final result = await _channel.invokeMethod('getDuration');
      return result as int?;
    } catch (e) {
      print('Error getting duration: $e');
      return null;
    }
  }
  
  /// Get current playback position in milliseconds
  static Future<int?> getPosition() async {
    try {
      final result = await _channel.invokeMethod('getPosition');
      return result as int?;
    } catch (e) {
      print('Error getting position: $e');
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
      print('Error seeking: $e');
      return null;
    }
  }
  
  /// Dispose player and free resources
  static Future<String?> dispose() async {
    try {
      final result = await _channel.invokeMethod('dispose');
      return result as String?;
    } catch (e) {
      print('Error disposing player: $e');
      return null;
    }
  }
  
  /// Get platform version
  static Future<String?> getPlatformVersion() async {
    try {
      final result = await _channel.invokeMethod('getPlatformVersion');
      return result as String?;
    } catch (e) {
      print('Error getting platform version: $e');
      return null;
    }
  }
}
```

### 5. Advanced Usage with Platform View

For iOS platform view support, add this additional widget:

```dart
Widget _buildPlayerView() {
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
    child: Text('Platform not supported'),
  );
}
```

### 6. Complete Example App

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS IVS Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VideoPlayerScreen(
        streamUrl: 'https://your-ivs-stream-url.m3u8',
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  
  const VideoPlayerScreen({Key? key, required this.streamUrl}) : super(key: key);
  
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isPlaying = false;
  double _volume = 1.0;
  String _playerState = 'IDLE';
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    try {
      await AwsIvsPlayer.createPlayer(widget.streamUrl);
      _updatePlayerState();
    } catch (e) {
      _showError('Error initializing player: $e');
    }
  }
  
  Future<void> _updatePlayerState() async {
    final state = await AwsIvsPlayer.getPlayerState();
    if (state != null) {
      setState(() {
        _playerState = state;
        _isPlaying = state == 'PLAYING';
      });
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AWS IVS Player'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Video player container
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.black,
            child: _buildPlayerView(),
          ),
          
          // Player state indicator
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              'Player State: $_playerState',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isPlaying ? null : _play,
                child: Text('Play'),
              ),
              ElevatedButton(
                onPressed: !_isPlaying ? null : _pause,
                child: Text('Pause'),
              ),
              ElevatedButton(
                onPressed: _stop,
                child: Text('Stop'),
              ),
            ],
          ),
          
          // Volume control
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Volume: ${(_volume * 100).round()}%'),
                Slider(
                  value: _volume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                    });
                    AwsIvsPlayer.setVolume(value);
                  },
                ),
              ],
            ),
          ),
          
          // Stream URL input
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _loadNewStream,
              child: Text('Load New Stream'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerView() {
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
      child: Center(
        child: Text(
          'Platform not supported',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
  
  Future<void> _play() async {
    final result = await AwsIvsPlayer.play();
    if (result != null) {
      _updatePlayerState();
    }
  }
  
  Future<void> _pause() async {
    final result = await AwsIvsPlayer.pause();
    if (result != null) {
      _updatePlayerState();
    }
  }
  
  Future<void> _stop() async {
    final result = await AwsIvsPlayer.stop();
    if (result != null) {
      _updatePlayerState();
    }
  }
  
  Future<void> _loadNewStream() async {
    // Show dialog to input new stream URL
    final controller = TextEditingController();
    final newUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Stream URL'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Load'),
          ),
        ],
      ),
    );
    
    if (newUrl != null && newUrl.isNotEmpty) {
      final result = await AwsIvsPlayer.loadStream(newUrl);
      if (result != null) {
        _updatePlayerState();
      }
    }
  }
  
  @override
  void dispose() {
    AwsIvsPlayer.dispose();
    super.dispose();
  }
}
```

## API Reference

### Available Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `createPlayer()` | `streamUrl: String` | `Future<String?>` | Initialize player with stream URL |
| `play()` | None | `Future<String?>` | Start playback |
| `pause()` | None | `Future<String?>` | Pause playback |
| `stop()` | None | `Future<String?>` | Stop playback |
| `loadStream()` | `streamUrl: String` | `Future<String?>` | Load new stream URL |
| `setVolume()` | `volume: double (0.0-1.0)` | `Future<String?>` | Set playback volume |
| `getPlayerState()` | None | `Future<String?>` | Get current player state |
| `getDuration()` | None | `Future<int?>` | Get video duration (ms) |
| `getPosition()` | None | `Future<int?>` | Get current position (ms) |
| `seekTo()` | `positionMs: int` | `Future<String?>` | Seek to position |
| `dispose()` | None | `Future<String?>` | Release player resources |

### Player States

- `IDLE` - Player is idle
- `READY` - Player is ready to play
- `BUFFERING` - Player is buffering
- `PLAYING` - Player is actively playing
- `ENDED` - Playback has ended

## Troubleshooting

### Android Issues

1. **Build errors**: Ensure Android API level 21+ and proper Kotlin version
2. **Network issues**: Check internet permissions in AndroidManifest.xml
3. **Gradle sync issues**: Clean and rebuild project

### iOS Issues

1. **Pod install errors**: Run `pod install --repo-update` in ios folder
2. **Build errors**: Ensure iOS 12.0+ deployment target
3. **Network issues**: Check App Transport Security settings

### Common Issues

1. **Stream not loading**: Verify stream URL is valid and accessible
2. **Audio issues**: Check device volume and app volume settings
3. **Performance issues**: Ensure device meets minimum requirements

## License

This plugin is provided as-is for educational and development purposes. Please ensure you have proper licensing for AWS IVS usage in production environments.

## Support

For AWS IVS related issues, refer to [AWS IVS Documentation](https://docs.aws.amazon.com/ivs/).
For Flutter plugin issues, check the implementation files and error logs.