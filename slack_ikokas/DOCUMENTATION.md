# slack_ikokas

This is a Flutter application that acts as a client for the official Slack API. It allows users to authenticate with Slack, view channels, send messages, and upload media.

The authentication process relies on Slack's OAuth2 flow with PKCE. The application uses the url_launcher package to open the Slack authorization URL in the device's browser. Once the user approves access, Slack redirects back to the application using a deep link, which is intercepted by the app_links package. The app then exchanges the authorization code for an access token via an API call. The crypto package is used to generate the necessary PKCE code verifier for this flow.

All communication with the Slack API is handled by the Dio HTTP client. Once the OAuth token is acquired, it is added to the headers of all subsequent Dio requests. The app makes GET requests to endpoints like `users.conversations` and `conversations.history` to fetch channel lists and messages. It makes POST requests to `chat.postMessage` to send new messages.

The application supports various media types. Users can select images or videos using the image_picker package, select documents with the file_picker package, or record audio using the record package. For uploading files, the app implements Slack's three-step external upload process via Dio.

Additionally, the app can acquire the device's coordinates using the geolocator package to share location data, and access the device's contact list using the flutter_contacts package. The permission_handler package manages the necessary permissions for these hardware features. For media playback, the app uses the video_player and chewie packages for video, and audioplayers for audio files.

Technologies used: Flutter, Dio, url_launcher, app_links, image_picker, file_picker, geolocator, flutter_contacts, video_player, chewie, record, audioplayers, permission_handler, path_provider, crypto.

## Working Flow
1. Open the app -> The app presents a login option.
2. Authenticate -> The app uses url_launcher to open the Slack OAuth page. After user approval, app_links intercepts the redirect URI, and the app uses Dio to exchange the code for an API token.
3. Fetch Data -> The app uses Dio to call Slack API endpoints, fetching the user's channels and messages, and renders them in the UI.
4. Send Message -> The user submits text. The app makes a POST request via Dio to the Slack API, which adds the message to the actual Slack channel.
5. Attach Media -> The user selects a file (via image_picker or file_picker), records audio, or grabs their location (via geolocator).
6. Upload to Slack -> The app executes the multi-step Slack file upload API flow via Dio to upload the asset and attach it to a conversation.
