package com.example.aws_ivs_flutter

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.annotation.NonNull
import com.amazonaws.ivs.player.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.net.URI

/** AWS IVS Flutter Plugin for Android */
class AwsIvsFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var context: Context? = null
  private var currentPlayer: Player? = null

  companion object {
    private const val TAG = "AwsIvsFlutterPlugin"
    private const val CHANNEL_NAME = "aws_ivs_flutter"
    private const val VIEW_TYPE = "aws_ivs_player_view"
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
    channel.setMethodCallHandler(this)
    
    // Register platform view factory
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory(VIEW_TYPE, AwsIvsPlayerViewFactory(context!!))
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "createPlayer" -> {
        try {
          val streamUrl = call.argument<String>("streamUrl")
          if (streamUrl.isNullOrEmpty()) {
            result.error("INVALID_URL", "Stream URL cannot be null or empty", null)
            return
          }
          
          // Create and configure player
          currentPlayer = IvsPlayerFactory.create(context!!)
          val uri = URI.create(streamUrl)
          currentPlayer?.load(uri)
          
          Log.d(TAG, "Player created successfully for URL: $streamUrl")
          result.success("Player created successfully")
        } catch (e: Exception) {
          Log.e(TAG, "Error creating player", e)
          result.error("PLAYER_CREATION_ERROR", "Failed to create player: ${e.message}", null)
        }
      }
      "play" -> {
        try {
          currentPlayer?.play()
          result.success("Player started")
        } catch (e: Exception) {
          Log.e(TAG, "Error starting playback", e)
          result.error("PLAYBACK_ERROR", "Failed to start playback: ${e.message}", null)
        }
      }
      "pause" -> {
        try {
          currentPlayer?.pause()
          result.success("Player paused")
        } catch (e: Exception) {
          Log.e(TAG, "Error pausing playback", e)
          result.error("PAUSE_ERROR", "Failed to pause playback: ${e.message}", null)
        }
      }
      "stop" -> {
        try {
          currentPlayer?.pause()
          result.success("Player stopped")
        } catch (e: Exception) {
          Log.e(TAG, "Error stopping playback", e)
          result.error("STOP_ERROR", "Failed to stop playback: ${e.message}", null)
        }
      }
      "dispose" -> {
        try {
          currentPlayer?.release()
          currentPlayer = null
          result.success("Player disposed")
        } catch (e: Exception) {
          Log.e(TAG, "Error disposing player", e)
          result.error("DISPOSE_ERROR", "Failed to dispose player: ${e.message}", null)
        }
      }
      "loadStream" -> {
        try {
          val streamUrl = call.argument<String>("streamUrl")
          if (streamUrl.isNullOrEmpty()) {
            result.error("INVALID_URL", "Stream URL cannot be null or empty", null)
            return
          }
          
          if (currentPlayer == null) {
            currentPlayer = IvsPlayerFactory.create(context!!)
          }
          
          val uri = URI.create(streamUrl)
          currentPlayer?.load(uri)
          Log.d(TAG, "Stream loaded: $streamUrl")
          result.success("Stream loaded successfully")
        } catch (e: Exception) {
          Log.e(TAG, "Error loading stream", e)
          result.error("LOAD_ERROR", "Failed to load stream: ${e.message}", null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    try {
      currentPlayer?.release()
      currentPlayer = null
    } catch (e: Exception) {
      Log.e(TAG, "Error during cleanup", e)
    }
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}

class AwsIvsPlayerViewFactory(private val context: Context) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    return AwsIvsPlayerView(context, viewId, args)
  }
}

class AwsIvsPlayerView(
  private val context: Context,
  private val viewId: Int,
  private val args: Any?
) : PlatformView, Player.Listener {

  private val frameLayout: FrameLayout = FrameLayout(context)
  private var player: Player? = null
  private var playerView: PlayerView? = null
  private var methodChannel: MethodChannel? = null

  companion object {
    private const val TAG = "AwsIvsPlayerView"
  }

  init {
    setupPlayer()
  }

  private fun setupPlayer() {
    try {
      // Initialize IVS Player
      player = IvsPlayerFactory.create(context)
      player?.addListener(this)

      // Create PlayerView with proper configuration
      playerView = PlayerView(context).apply {
        player = this@AwsIvsPlayerView.player
        layoutParams = FrameLayout.LayoutParams(
          FrameLayout.LayoutParams.MATCH_PARENT,
          FrameLayout.LayoutParams.MATCH_PARENT
        )
        // Enable video scaling
        setVideoScaleMode(PlayerView.VideoScaleMode.ASPECT_FIT)
      }

      frameLayout.addView(playerView)

      // Load stream URL if provided in creation parameters
      val creationParams = args as? Map<String, Any>
      val streamUrl = creationParams?.get("streamUrl") as? String
      if (!streamUrl.isNullOrEmpty()) {
        loadStream(streamUrl)
      }

      Log.d(TAG, "Player view initialized successfully")

    } catch (e: Exception) {
      Log.e(TAG, "Error setting up player", e)
    }
  }

  fun loadStream(streamUrl: String) {
    try {
      if (player == null) {
        player = IvsPlayerFactory.create(context)
        player?.addListener(this)
        playerView?.player = player
      }

      val uri = URI.create(streamUrl)
      player?.load(uri)
      Log.d(TAG, "Stream loaded: $streamUrl")
    } catch (e: Exception) {
      Log.e(TAG, "Error loading stream: $streamUrl", e)
    }
  }

  fun play() {
    try {
      player?.play()
      Log.d(TAG, "Playback started")
    } catch (e: Exception) {
      Log.e(TAG, "Error starting playback", e)
    }
  }

  fun pause() {
    try {
      player?.pause()
      Log.d(TAG, "Playback paused")
    } catch (e: Exception) {
      Log.e(TAG, "Error pausing playback", e)
    }
  }

  fun stop() {
    try {
      player?.pause()
      Log.d(TAG, "Playback stopped")
    } catch (e: Exception) {
      Log.e(TAG, "Error stopping playback", e)
    }
  }

  fun seekTo(positionMs: Long) {
    try {
      player?.seekTo(positionMs)
      Log.d(TAG, "Seeking to position: $positionMs")
    } catch (e: Exception) {
      Log.e(TAG, "Error seeking to position: $positionMs", e)
    }
  }

  fun setVolume(volume: Float) {
    try {
      player?.volume = volume.coerceIn(0.0f, 1.0f)
      Log.d(TAG, "Volume set to: $volume")
    } catch (e: Exception) {
      Log.e(TAG, "Error setting volume: $volume", e)
    }
  }

  fun getPlayerState(): Player.State? {
    return player?.state
  }

  fun getDuration(): Long {
    return player?.duration ?: 0L
  }

  fun getPosition(): Long {
    return player?.position ?: 0L
  }

  fun getQualities(): List<Quality> {
    return player?.qualities ?: emptyList()
  }

  fun setQuality(quality: Quality) {
    try {
      player?.quality = quality
      Log.d(TAG, "Quality set to: ${quality.name}")
    } catch (e: Exception) {
      Log.e(TAG, "Error setting quality", e)
    }
  }

  override fun getView(): View = frameLayout

  override fun dispose() {
    try {
      player?.removeListener(this)
      player?.release()
      player = null
      playerView = null
      Log.d(TAG, "Player disposed")
    } catch (e: Exception) {
      Log.e(TAG, "Error disposing player", e)
    }
  }

  // Player.Listener implementation with comprehensive event handling
  override fun onCue(cue: Cue) {
    Log.d(TAG, "Cue received: ${cue.textCue}")
    // Send event to Flutter if needed
  }

  override fun onDurationChanged(duration: Long) {
    Log.d(TAG, "Duration changed: $duration ms")
    // Send event to Flutter
  }

  override fun onError(exception: PlayerException) {
    Log.e(TAG, "Player error: ${exception.errorMessage}", exception)
    // Send error event to Flutter
  }

  override fun onMetadata(data: String, buffer: ByteArray) {
    Log.d(TAG, "Metadata received: $data")
    // Send metadata to Flutter if needed
  }

  override fun onQualityChanged(quality: Quality) {
    Log.d(TAG, "Quality changed: ${quality.name} - ${quality.width}x${quality.height} @ ${quality.bitrate} bps")
    // Send quality change event to Flutter
  }

  override fun onRebuffering() {
    Log.d(TAG, "Player rebuffering")
    // Send buffering event to Flutter
  }

  override fun onSeekCompleted(position: Long) {
    Log.d(TAG, "Seek completed: $position ms")
    // Send seek completion event to Flutter
  }

  override fun onVideoSizeChanged(width: Int, height: Int) {
    Log.d(TAG, "Video size changed: ${width}x${height}")
    // Send video size change event to Flutter
  }

  override fun onStateChanged(state: Player.State) {
    val stateString = when (state) {
      Player.State.IDLE -> "IDLE"
      Player.State.READY -> "READY"
      Player.State.BUFFERING -> "BUFFERING"
      Player.State.PLAYING -> "PLAYING"
      Player.State.ENDED -> "ENDED"
    }
    Log.d(TAG, "Player state changed: $stateString")
    // Send state change event to Flutter
  }
}
