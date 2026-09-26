package com.example.reel_like

import android.content.Context
import android.view.View
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class NativeVideoPlayer(
    private val context: Context,
    viewId: Int,
    creationParams: Map<String?, Any?>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val playerView: PlayerView = PlayerView(context)
    private var player: ExoPlayer? = null
    private var videoUrl: String? = null

    private var eventSink: EventChannel.EventSink? = null
    private val methodChannel = MethodChannel(messenger, "com.example.reel_like/native_video_player_$viewId")
    private val eventChannel = EventChannel(messenger, "com.example.reel_like/native_video_player_events_$viewId")

    private val playerListener = object : Player.Listener {
        override fun onPlaybackStateChanged(playbackState: Int) {
            when (playbackState) {
                Player.STATE_BUFFERING -> eventSink?.success(mapOf("event" to "buffering"))
                Player.STATE_READY -> eventSink?.success(mapOf("event" to "ready"))
                Player.STATE_ENDED -> eventSink?.success(mapOf("event" to "ended"))
            }
        }

        override fun onPlayerError(error: PlaybackException) {
            eventSink?.success(mapOf("event" to "error", "message" to error.message))
        }
    }

    init {
        videoUrl = creationParams?.get("url") as String?
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        setupPlayer()
    }

    private fun setupPlayer() {
        videoUrl?.let {
            player = ExoPlayerManager.getPlayer(context, it)
            playerView.player = player
            playerView.useController = false
            player?.addListener(playerListener)
        }
    }

    override fun getView(): View = playerView

    override fun dispose() {
        player?.removeListener(playerListener)
        playerView.player = null
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                player?.play()
                result.success(null)
            }
            "pause" -> {
                player?.pause()
                result.success(null)
            }
            "retry" -> {
                player?.prepare()
                player?.play()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }
}
