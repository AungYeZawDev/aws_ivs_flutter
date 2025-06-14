package com.example.aws_ivs_flutter

import android.app.Activity
import android.content.Context
import android.net.Uri
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
      "createPlayer" -> createPlayer(call, result)
      "play" -> play(result)
      "pause" -> pause(result)
      "stop" -> stop(result)
      "loadStream" -> loadStream(call, result)
      "setVolume" -> setVolume(call, result)
      "getPlayerState" -> getPlayerState(result)
      "getDuration" -> getDuration(result)
      "getPosition" -> getPosition(result)
      "seekTo" -> seekTo(call, result)
      "dispose" -> dispose(result)
      else -> result.notImplemented()
    }
  }

  private fun createPlayer(call: MethodCall, result: Result) {
    try {
      val streamUrl = call.argument<String>("streamUrl")
      if (streamUrl.isNullOrEmpty()) {
        result.error("INVALID_URL", "Stream URL cannot be null or empty", null)
        return
      }

      currentPlayer = Player.Factory.create(context!!)
      val uri = Uri.parse(streamUrl)
      currentPlayer?.load(uri)

      Log.d(TAG, "Player created successfully for URL: $streamUrl")
      result.success("Player created successfully")
    } catch (e: Exception) {
      Log.e(TAG, "Error creating player", e)
      result.error("PLAYER_CREATION_ERROR", "Failed to create player: ${e.message}", null)
    }
  }

  private fun loadStream(call: MethodCall, result: Result) {
    try {
      val streamUrl = call.argument<String>("streamUrl")
      if (streamUrl.isNullOrEmpty()) {
        result.error("INVALID_URL", "Stream URL cannot be null or empty", null)
        return
      }

      if (currentPlayer == null) {
        currentPlayer = Player.Factory.create(context!!)
      }

      val uri = Uri.parse(streamUrl)
      currentPlayer?.load(uri)

      Log.d(TAG, "Stream loaded: $streamUrl")
      result.success("Stream loaded successfully")
    } catch (e: Exception) {
      Log.e(TAG, "Error loading stream", e)
      result.error("LOAD_ERROR", "Failed to load stream: ${e.message}", null)
    }
  }

  private fun play(result: Result) {
    try {
      currentPlayer?.play()
      result.success("Playing")
    } catch (e: Exception) {
      Log.e(TAG, "Error starting playback", e)
      result.error("PLAY_ERROR", "Error playing: ${e.message}", null)
    }
  }

  private fun pause(result: Result) {
    try {
      currentPlayer?.pause()
      result.success("Paused")
    } catch (e: Exception) {
      Log.e(TAG, "Error pausing playback", e)
      result.error("PAUSE_ERROR", "Error pausing: ${e.message}", null)
    }
  }

  private fun stop(result: Result) {
    try {
      currentPlayer?.pause()
      result.success("Stopped")
    } catch (e: Exception) {
      Log.e(TAG, "Error stopping playback", e)
      result.error("STOP_ERROR", "Error stopping: ${e.message}", null)
    }
  }

  private fun setVolume(call: MethodCall, result: Result) {
    try {
      val volume = call.argument<Double>("volume") ?: 1.0
      currentPlayer?.volume = volume.toFloat()
      result.success("Volume set to $volume")
    } catch (e: Exception) {
      Log.e(TAG, "Error setting volume", e)
      result.error("SET_VOLUME_ERROR", "Error setting volume: ${e.message}", null)
    }
  }

  private fun getPlayerState(result: Result) {
    try {
      val state = when (currentPlayer?.state) {
        Player.State.IDLE -> "IDLE"
        Player.State.READY -> "READY"
        Player.State.BUFFERING -> "BUFFERING"
        Player.State.PLAYING -> "PLAYING"
        Player.State.ENDED -> "ENDED"
        else -> "UNKNOWN"
      }
      result.success(state)
    } catch (e: Exception) {
      Log.e(TAG, "Error getting player state", e)
      result.error("GET_STATE_ERROR", "Error getting player state: ${e.message}", null)
    }
  }

  private fun getDuration(result: Result) {
    try {
      val duration = currentPlayer?.duration ?: 0L
      result.success(duration)
    } catch (e: Exception) {
      Log.e(TAG, "Error getting duration", e)
      result.error("GET_DURATION_ERROR", "Error getting duration: ${e.message}", null)
    }
  }

  private fun getPosition(result: Result) {
    try {
      val position = currentPlayer?.position ?: 0L
      result.success(position)
    } catch (e: Exception) {
      Log.e(TAG, "Error getting position", e)
      result.error("GET_POSITION_ERROR", "Error getting position: ${e.message}", null)
    }
  }

  private fun seekTo(call: MethodCall, result: Result) {
    try {
      val position = call.argument<Long>("position") ?: 0L
      currentPlayer?.seekTo(position)
      result.success("Seeked to $position")
    } catch (e: Exception) {
      Log.e(TAG, "Error seeking", e)
      result.error("SEEK_ERROR", "Error seeking: ${e.message}", null)
    }
  }

  private fun dispose(result: Result) {
    try {
      currentPlayer?.release()
      currentPlayer = null
      result.success("Player disposed")
    } catch (e: Exception) {
      Log.e(TAG, "Error disposing player", e)
      result.error("DISPOSE_ERROR", "Error disposing player: ${e.message}", null)
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
  private val creationParams: Any?
) : PlatformView, Player.Listener() {

  private val frameLayout: FrameLayout = FrameLayout(context)
  private var player: Player? = null
  private var playerView: PlayerView? = null

  companion object {
    private const val TAG = "AwsIvsPlayerView"
  }

  init {
    setupPlayer()
  }

  private fun setupPlayer() {
  try {
    // 1️⃣ Create PlayerView (it auto-initializes its own Player)
    playerView = PlayerView(context).apply {
      layoutParams = FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
      )
    }
    // Attach to your UI container
    frameLayout.addView(playerView)

    // 2️⃣ Retrieve the internal player from the view
    player = playerView?.player    // ✅ 'getPlayer()' in Java, '.player' getter in Kotlin
    player?.addListener(this)

    // Ensure the view is visible and on top
    playerView?.requestLayout()
    playerView?.invalidate()
    playerView?.elevation = 999f
    frameLayout.bringChildToFront(playerView)

    // 3️⃣ Load initial stream URL if provided
    val params = creationParams as? Map<String, Any>
    val streamUrl = params?.get("streamUrl") as? String
    if (!streamUrl.isNullOrEmpty()) {
      loadStream(streamUrl)
    }

    Log.d(TAG, "Player view initialized successfully")
  } catch (e: Exception) {
    Log.e(TAG, "Error setting up player", e)
  }
}

  private fun loadStream(streamUrl: String) {
  try {
    player?.let {
      it.load(Uri.parse(streamUrl))
      it.play()
      Log.d(TAG, "Stream loaded: $streamUrl")
    }
  } catch (e: Exception) {
    Log.e(TAG, "Error loading stream: $streamUrl", e)
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

  // Player.Listener implementation
  override fun onCue(cue: Cue) {
    Log.d(TAG, "Cue received")
  }

  override fun onDurationChanged(duration: Long) {
    Log.d(TAG, "Duration changed: $duration ms")
  }

  override fun onError(exception: PlayerException) {
    Log.e(TAG, "Player error: ${exception.errorMessage}", exception)
  }

  override fun onQualityChanged(quality: Quality) {
    Log.d(TAG, "Quality changed: ${quality.name}")
  }

  override fun onRebuffering() {
    Log.d(TAG, "Player rebuffering")
  }

  override fun onSeekCompleted(position: Long) {
    Log.d(TAG, "Seek completed: $position ms")
  }

  override fun onVideoSizeChanged(width: Int, height: Int) {
    Log.d(TAG, "Video size changed: ${width}x${height}")
  }

  override fun onStateChanged(state: Player.State) {
  if (state == Player.State.READY) player?.play()
}
}