# slack_ikokas

This is a Flutter Slack client application that integrates directly with the real Slack API. Users authenticate through Slack's OAuth2 flow, browse their workspace channels, send and receive messages, and share files, images, videos, audio recordings, location, and contacts — all through actual Slack API calls.

The authentication flow is a full OAuth2 implementation with PKCE. The AuthController opens the Slack OAuth URL in the device browser using url_launcher. After the user authorizes the app in their Slack workspace, Slack redirects back to the app via a deep link, which app_links captures. The controller extracts the authorization code from the deep link and exchanges it for an access token by calling the exchangeCode method on the SlackApiService, which posts to Slack's oauth.v2.access endpoint. The PKCE code verifier is generated using the crypto package. Once the token is received, it's stored in the SlackApiService singleton and attached to all subsequent API requests via a Dio interceptor that adds the Bearer token to the Authorization header.

The SlackApiService is the heart of the app — a singleton class with a Dio client configured for the Slack API base URL. It provides methods for every Slack operation: getChannels fetches the user's conversations (public, private, and group DMs) via users.conversations, createChannel creates new channels via conversations.create, openGroupChat opens group DMs, and inviteToChannel adds users to channels. For messaging, getMessages fetches channel history via conversations.history, sendMessage posts via chat.postMessage (with optional username and emoji icon), updateMessage edits messages, and deleteMessage removes them.

File sharing uses Slack's three-step external upload process. First, uploadFile calls files.getUploadURLExternal to get a presigned URL and file ID. Then it uploads the actual file to that URL using multipart form data. Finally, it calls files.completeUploadExternal to associate the file with a channel and add an optional message. File downloads go through downloadFileBytes, which handles authentication redirects (301/302) by following the redirect chain and adding the Bearer token.

The ChannelController manages the channel list state, and the ChatController handles the message flow within a channel. The chat view supports text messages plus rich media — users can pick images and videos with image_picker, select documents with file_picker, record audio using the record package, share their GPS location via geolocator (sent as a Google Maps link in the message), and share device contacts through flutter_contacts. Videos are played back with video_player and chewie, and audio files use audioplayers. All permissions are managed through permission_handler.

The getUserName method on the service resolves Slack user IDs to display names by calling users.info, with results cached in a map to avoid repeated API calls.

Technologies used: Flutter, Dio, url_launcher, app_links, image_picker, file_picker, geolocator, flutter_contacts, video_player, chewie, record, audioplayers, permission_handler, path_provider, crypto.

## Working Flow
1. Open the app -> The Login View appears.
2. Click "Login with Slack" -> The app launches your phone's browser taking you to the Slack authorization page.
3. Approve access -> Slack redirects back to the app via a deep link. The app captures this, exchanges the code for a Bearer token, and saves it.
4. Land on Channel List -> The app makes an API call to Slack to fetch and display all your workspace conversations.
5. Click a channel -> The Chat View opens, fetching message history from Slack API.
6. Type a message and send -> An API request posts your message to the channel, and it appears in the actual Slack app for other users.
7. Click the Attachment icon -> Choose an option like "Location". The app grabs your GPS coordinates and sends a Google Maps link to the Slack channel.
8. Click "Record Audio" -> You speak into the mic, and the app uploads the audio file using Slack's 3-step file upload API, attaching it to the conversation.
