package com.example.reel_like

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "NativeVideoPlayerView",
            NativeVideoPlayerFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        ExoPlayerManager.releaseAll()
    }
}
