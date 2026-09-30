# reel_like

This is a short video application built with Flutter and Riverpod. A defining feature of this project is its integration of native Android code for optimized video playback, alongside cloud services for storage and database management.

The application uses a Riverpod controller to manage the state of the video feed. Video metadata is stored in and fetched from Firebase Cloud Firestore.

Instead of relying solely on standard Flutter video packages for playback, the application implements a custom native Android video player. This is achieved using a Flutter Platform View (AndroidView). A MethodChannel is established to send commands from Flutter to the native Android code (e.g., play, pause, initialize). An EventChannel is used to stream playback state updates (e.g., buffering, playing, errors) from the native Android side back to the Flutter UI, allowing the app to show loading indicators or handle errors reactively. The video_player package is also included in the project dependencies, likely serving as a fallback or for specific secondary uses.

For uploading new content, the app uses the image_picker package to allow the user to select a video file from their device. The app then uses the http package to send the file to Cloudinary's upload API. Upon a successful upload, Cloudinary returns a video URL. The app then saves this URL, along with other video metadata, into Cloud Firestore, which triggers a state update in Riverpod to include the new video in the feed.

Technologies used: Flutter, flutter_riverpod, Firebase Core, Cloud Firestore, http, image_picker, video_player, and native Android code using MethodChannel, EventChannel, and PlatformView.

## Working Flow
1. Open the app -> The Riverpod controller fetches video metadata from Cloud Firestore and updates the state to display a list of videos.
2. View Video -> The Flutter UI instantiates a Platform View, which triggers the creation of a native Android video player.
3. Native Playback -> The Flutter app uses a MethodChannel to instruct the native player to load and play the video URL. The native player streams its status back via an EventChannel, which the UI uses to show buffering states.
4. Upload Video -> The user selects a video file via image_picker.
5. Process Upload -> The app makes an HTTP POST request to Cloudinary with the file.
6. Save Metadata -> Once Cloudinary returns the uploaded URL, the app writes a new document to Cloud Firestore. The Riverpod state updates, adding the new video to the app's feed.
