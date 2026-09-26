# reel_like

This is a Flutter short video application inspired by Instagram Reels and TikTok. It uses Riverpod for state management and features a native Android video player built through platform channels — this is one of the projects that uses native code.

The app has two main screens. The ReelFeedScreen displays videos in a vertical PageView that users swipe through, just like Reels. The ReelUploadScreen lets users select a video from their gallery using image_picker and upload it.

The video playback is where things get interesting. Instead of using Flutter's built-in video_player widget for the feed, the app uses a NativeVideoPlayerWidget that embeds an AndroidView — a native Android platform view. When this view is created, it registers a MethodChannel at "com.example.reel_like/native_video_player_{id}" for sending commands (play, pause, retry) and an EventChannel at "com.example.reel_like/native_video_player_events_{id}" for receiving playback events (buffering, ready, playing, error). The native Android side (written in Kotlin or Java in the android directory) creates an actual native video player that performs better than Flutter's video_player for this kind of rapid-swipe feed experience. The widget listens to the event stream and shows buffering indicators or error states with a retry button based on what the native player reports.

When users upload a video, the CloudinaryService sends the video file to Cloudinary's video upload API endpoint using the http package with multipart form data. After Cloudinary returns the secure URL, the FirebaseService saves the video metadata (URL, user ID, title, creation time) as a document in Cloud Firestore. The ReelController (a Riverpod provider) manages loading the reel list from Firestore and adding new uploads.

The video_player package is still included as a fallback, but the primary playback mechanism is the native Android implementation. Note that the native player is only implemented for Android using AndroidView — an iOS implementation using UIKitView would need to be added separately.

Technologies used: Flutter, flutter_riverpod, Firebase Core, Cloud Firestore, http, image_picker, video_player, and native Android code using MethodChannel, EventChannel, and PlatformView (AndroidView).

## Working Flow
1. Open the app -> The Reel Feed Screen opens immediately, presenting a vertical swipeable PageView of videos.
2. Watch a video -> The AndroidView platform view initializes, communicating with Kotlin/Java native code via a MethodChannel to play the video smoothly.
3. Swipe up -> The PageView moves to the next video, triggering the native video player to load the next URL.
4. Click the Upload icon -> The image picker opens, letting you select a video from your gallery.
5. Confirm upload -> The CloudinaryService uploads the file to the cloud. Upon success, the FirebaseService stores the URL and title in Firestore.
6. Upload completes -> The Riverpod ReelController updates the state, and your new video is added to the feed.
