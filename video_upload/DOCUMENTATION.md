# video_upload

This is a full-stack video upload and management application with a Flutter frontend and a Node.js backend. The app uses the BLoC pattern for state management and features video selection, editing, cropping, and uploading to Cloudinary.

The app uses two main BLoCs: UploadBloc for handling the video upload flow and VideoListBloc for fetching and displaying the feed. When the user selects a video using the image_picker package, the video is passed to an editing interface built with video_editor. Here, the user can trim the video. After trimming, the user can navigate to custom crop screens where they can adjust crop parameters. The actual video processing (trimming and cropping) is handled by the ffmpeg_kit_flutter_new package, which executes FFmpeg commands on the device to create the final processed video file.

Once the video is ready, the CloudinaryService takes over. It uses Dio to upload the processed video file directly to Cloudinary. After a successful upload, Cloudinary returns a secure URL. The app then makes a POST request using the VideoRepository to the Express.js backend, sending the video metadata (like title and the Cloudinary URL). The backend, which uses Mongoose, saves this metadata into a MongoDB database.

The home screen displays a feed of all uploaded videos. The VideoListBloc fetches this list from the backend API, and the videos are displayed using the video_player package for playback. The backend is a standard Express setup with routes, controllers, and models, using dotenv for environment variables and cors for cross-origin requests.

Technologies used: Flutter, flutter_bloc, Dio, image_picker, video_player, video_editor, ffmpeg_kit_flutter_new, equatable, path_provider, Node.js, Express.js, MongoDB, Mongoose, Cloudinary API, dotenv.

## Working Flow
1. Open the app -> The Home Screen loads and the VideoListBloc fetches the list of videos from the Node.js backend.
2. Scroll through the feed -> Videos are displayed, and you can tap to play them using the video player.
3. Click the Upload button -> The image picker opens, allowing you to select a video from your gallery.
4. Select a video -> The video editor screen opens where you can trim the video timeline.
5. Click the Crop option -> A screen opens where you can adjust the crop area of the video.
6. Click Save/Process -> FFmpeg processes the video locally on your device to apply the trim and crop.
7. Click Upload -> The processed video is uploaded to Cloudinary, and its metadata is saved to the MongoDB database via the Node.js API.
8. Upload completes -> You are returned to the Home Screen, and the new video appears in the feed.
