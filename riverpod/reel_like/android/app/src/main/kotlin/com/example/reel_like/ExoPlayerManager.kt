package com.example.reel_like

import android.content.Context
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer

object ExoPlayerManager {
    private const val MAX_PLAYERS = 3
    private val playerPool = mutableListOf<ExoPlayer>()
    private val activePlayers = mutableMapOf<String, ExoPlayer>()

    fun getPlayer(context: Context, url: String): ExoPlayer {
        if (activePlayers.containsKey(url)) {
            return activePlayers[url]!!
        }

        val player: ExoPlayer
        if (playerPool.size < MAX_PLAYERS) {
            player = createNewPlayer(context)
            playerPool.add(player)
        } else {
            val recycledUrl = activePlayers.keys.first() 
            player = activePlayers.remove(recycledUrl)!!
            player.stop()
            player.clearMediaItems()
        }

        val mediaItem = MediaItem.fromUri(url)
        val dataSourceFactory = VideoCacheManager.getCacheDataSourceFactory(context)
        val mediaSource = androidx.media3.exoplayer.source.DefaultMediaSourceFactory(context)
            .setDataSourceFactory(dataSourceFactory)
            .createMediaSource(mediaItem)
        
        player.setMediaSource(mediaSource)
        player.prepare()
        activePlayers[url] = player

        return player
    }

    private fun createNewPlayer(context: Context): ExoPlayer {
        return ExoPlayer.Builder(context).build().apply {
            repeatMode = Player.REPEAT_MODE_ONE
        }
    }

    fun releaseAll() {
        playerPool.forEach { it.release() }
        playerPool.clear()
        activePlayers.clear()
    }
}
