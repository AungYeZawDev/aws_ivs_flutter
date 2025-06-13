import Flutter
import UIKit
import AmazonIVSPlayer

public class AwsIvsFlutterPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var currentPlayer: IVSPlayer?
    private var playerView: IVSPlayerView?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "aws_ivs_flutter", binaryMessenger: registrar.messenger())
        let instance = AwsIvsFlutterPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Register platform view factory
        let factory = AwsIvsPlayerViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "aws_ivs_player_view")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            
        case "createPlayer":
            createPlayer(call: call, result: result)
            
        case "play":
            playVideo(result: result)
            
        case "pause":
            pauseVideo(result: result)
            
        case "stop":
            stopVideo(result: result)
            
        case "dispose":
            disposePlayer(result: result)
            
        case "loadStream":
            loadStream(call: call, result: result)
            
        case "setVolume":
            setVolume(call: call, result: result)
            
        case "getPlayerState":
            getPlayerState(result: result)
            
        case "getDuration":
            getDuration(result: result)
            
        case "getPosition":
            getPosition(result: result)
            
        case "seekTo":
            seekTo(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func createPlayer(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let streamUrl = args["streamUrl"] as? String,
              !streamUrl.isEmpty else {
            result(FlutterError(code: "INVALID_URL", message: "Stream URL cannot be null or empty", details: nil))
            return
        }
        
        do {
            // Create IVS Player
            currentPlayer = IVSPlayer()
            
            // Load the stream
            if let url = URL(string: streamUrl) {
                currentPlayer?.load(url)
                print("AwsIvsFlutterPlugin: Player created successfully for URL: \(streamUrl)")
                result("Player created successfully")
            } else {
                result(FlutterError(code: "INVALID_URL", message: "Invalid stream URL format", details: nil))
            }
        } catch {
            print("AwsIvsFlutterPlugin: Error creating player: \(error)")
            result(FlutterError(code: "PLAYER_CREATION_ERROR", message: "Failed to create player: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func playVideo(result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        do {
            player.play()
            print("AwsIvsFlutterPlugin: Playback started")
            result("Player started")
        } catch {
            print("AwsIvsFlutterPlugin: Error starting playback: \(error)")
            result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to start playback: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func pauseVideo(result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        do {
            player.pause()
            print("AwsIvsFlutterPlugin: Playback paused")
            result("Player paused")
        } catch {
            print("AwsIvsFlutterPlugin: Error pausing playback: \(error)")
            result(FlutterError(code: "PAUSE_ERROR", message: "Failed to pause playback: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func stopVideo(result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        do {
            player.pause()
            print("AwsIvsFlutterPlugin: Playback stopped")
            result("Player stopped")
        } catch {
            print("AwsIvsFlutterPlugin: Error stopping playback: \(error)")
            result(FlutterError(code: "STOP_ERROR", message: "Failed to stop playback: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func disposePlayer(result: @escaping FlutterResult) {
        do {
            currentPlayer?.pause()
            currentPlayer = nil
            playerView = nil
            print("AwsIvsFlutterPlugin: Player disposed")
            result("Player disposed")
        } catch {
            print("AwsIvsFlutterPlugin: Error disposing player: \(error)")
            result(FlutterError(code: "DISPOSE_ERROR", message: "Failed to dispose player: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func loadStream(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let streamUrl = args["streamUrl"] as? String,
              !streamUrl.isEmpty else {
            result(FlutterError(code: "INVALID_URL", message: "Stream URL cannot be null or empty", details: nil))
            return
        }
        
        do {
            if currentPlayer == nil {
                currentPlayer = IVSPlayer()
            }
            
            if let url = URL(string: streamUrl) {
                currentPlayer?.load(url)
                print("AwsIvsFlutterPlugin: Stream loaded: \(streamUrl)")
                result("Stream loaded successfully")
            } else {
                result(FlutterError(code: "INVALID_URL", message: "Invalid stream URL format", details: nil))
            }
        } catch {
            print("AwsIvsFlutterPlugin: Error loading stream: \(error)")
            result(FlutterError(code: "LOAD_ERROR", message: "Failed to load stream: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func setVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let volume = args["volume"] as? Double else {
            result(FlutterError(code: "INVALID_VOLUME", message: "Invalid volume value", details: nil))
            return
        }
        
        let clampedVolume = max(0.0, min(1.0, volume))
        player.volume = Float(clampedVolume)
        print("AwsIvsFlutterPlugin: Volume set to: \(clampedVolume)")
        result("Volume set successfully")
    }
    
    private func getPlayerState(result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        let stateString: String
        switch player.state {
        case .idle:
            stateString = "IDLE"
        case .ready:
            stateString = "READY"
        case .buffering:
            stateString = "BUFFERING"
        case .playing:
            stateString = "PLAYING"
        case .ended:
            stateString = "ENDED"
        @unknown default:
            stateString = "UNKNOWN"
        }
        
        result(stateString)
    }
    
    private func getDuration(result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        let duration = player.duration.seconds * 1000 // Convert to milliseconds
        result(Int64(duration))
    }
    
    private func getPosition(result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        let position = player.position.seconds * 1000 // Convert to milliseconds
        result(Int64(position))
    }
    
    private func seekTo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let player = currentPlayer else {
            result(FlutterError(code: "PLAYER_NOT_INITIALIZED", message: "Player not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let positionMs = args["position"] as? Int64 else {
            result(FlutterError(code: "INVALID_POSITION", message: "Invalid seek position", details: nil))
            return
        }
        
        let positionSeconds = CMTime(seconds: Double(positionMs) / 1000.0, preferredTimescale: 1000)
        player.seek(to: positionSeconds)
        print("AwsIvsFlutterPlugin: Seeking to position: \(positionMs) ms")
        result("Seek completed")
    }
}

// MARK: - Platform View Factory
class AwsIvsPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AwsIvsPlayerViewController(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Platform View Controller
class AwsIvsPlayerViewController: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var player: IVSPlayer?
    private var playerView: IVSPlayerView?
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        _view = UIView()
        super.init()
        
        createPlayer(args: args)
    }
    
    func view() -> UIView {
        return _view
    }
    
    private func createPlayer(args: Any?) {
        do {
            // Create IVS Player
            player = IVSPlayer()
            player?.delegate = self
            
            // Create IVS Player View
            playerView = IVSPlayerView()
            playerView?.player = player
            
            // Configure player view
            if let playerView = playerView {
                playerView.videoGravity = .resizeAspect
                playerView.translatesAutoresizingMaskIntoConstraints = false
                _view.addSubview(playerView)
                
                // Add constraints
                NSLayoutConstraint.activate([
                    playerView.topAnchor.constraint(equalTo: _view.topAnchor),
                    playerView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
                    playerView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
                    playerView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
                ])
            }
            
            // Load stream URL if provided in creation parameters
            if let creationParams = args as? [String: Any],
               let streamUrl = creationParams["streamUrl"] as? String,
               !streamUrl.isEmpty,
               let url = URL(string: streamUrl) {
                player?.load(url)
                print("AwsIvsPlayerViewController: Stream loaded from creation params: \(streamUrl)")
            }
            
            print("AwsIvsPlayerViewController: Player view initialized successfully")
            
        } catch {
            print("AwsIvsPlayerViewController: Error setting up player: \(error)")
        }
    }
}

// MARK: - IVS Player Delegate
extension AwsIvsPlayerViewController: IVSPlayerDelegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayerState) {
        let stateString: String
        switch state {
        case .idle:
            stateString = "IDLE"
        case .ready:
            stateString = "READY"
        case .buffering:
            stateString = "BUFFERING"
        case .playing:
            stateString = "PLAYING"
        case .ended:
            stateString = "ENDED"
        @unknown default:
            stateString = "UNKNOWN"
        }
        print("AwsIvsPlayerViewController: Player state changed: \(stateString)")
    }
    
    func player(_ player: IVSPlayer, didFailWithError error: Error) {
        print("AwsIvsPlayerViewController: Player error: \(error.localizedDescription)")
    }
    
    func player(_ player: IVSPlayer, didChangeVideoSize videoSize: CGSize) {
        print("AwsIvsPlayerViewController: Video size changed: \(videoSize)")
    }
    
    func player(_ player: IVSPlayer, didChangeDuration duration: CMTime) {
        print("AwsIvsPlayerViewController: Duration changed: \(duration.seconds) seconds")
    }
    
    func player(_ player: IVSPlayer, didOutputMetadataTimedMetadataGroup metadataGroup: AVTimedMetadataGroup) {
        print("AwsIvsPlayerViewController: Metadata received")
    }
    
    func playerWillRebuffer(_ player: IVSPlayer) {
        print("AwsIvsPlayerViewController: Player will rebuffer")
    }
    
    func player(_ player: IVSPlayer, didSeekTo time: CMTime) {
        print("AwsIvsPlayerViewController: Seek completed to: \(time.seconds) seconds")
    }
}