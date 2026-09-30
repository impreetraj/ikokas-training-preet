# video_upload

This is an application designed for selecting, editing, and uploading video files. The frontend is built with Flutter and uses the BLoC pattern for state management. It communicates with a backend service to handle the final uploads.

The application allows users to select videos from their device using the image_picker package. Once a video is selected, the application utilizes the video_editor package to provide a UI for trimming and cropping the video. The actual video processing (applying the trims and crops) is performed on the device using the ffmpeg_kit_flutter_new package, which executes FFmpeg commands to generate the final modified video file.

For network operations, the app uses both the http and dio packages. After the video is edited and processed locally, the application sends the file to a cloud storage service (such as Cloudinary) or a custom backend via HTTP requests. 

The video_player package is included to preview the videos, and the equatable package is used alongside flutter_bloc to efficiently compare state changes.

Technologies used: Flutter, flutter_bloc, http, dio, image_picker, video_player, video_editor, ffmpeg_kit_flutter_new, equatable, path_provider.

## Working Flow
1. Open the app -> The BLoC initializes the application state.
2. Select Video -> The user uses the image_picker to choose a video file from local storage.
3. Edit Video -> The video is loaded into the video_editor interface where the user can adjust trim markers or crop boundaries.
4. Process Video -> Upon confirmation, the app uses ffmpeg_kit_flutter_new to process the file according to the edit parameters.
5. Upload Video -> The BLoC sends an HTTP request (via Dio/http) with the processed file to the backend server or cloud storage for final upload.
