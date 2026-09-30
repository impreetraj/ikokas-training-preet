# whatsapp_chat

This is a Flutter messaging application designed to interface with a backend for real-time communication, simulating a WhatsApp-like experience. 

The application relies heavily on network communication. It uses the Dio package to make standard HTTP REST API requests to a backend server (e.g., for user authentication or fetching initial data). For real-time messaging, the application establishes a persistent connection to a Node.js backend using the socket_io_client package. This allows the app to send and receive chat messages instantly without needing to poll the server.

The application supports various types of message attachments. It uses the image_picker package to allow users to select photos or videos from their gallery or camera. It uses the file_picker package for selecting documents or other generic files from the device storage. Additionally, it uses the location package to acquire the device's current GPS coordinates, allowing users to share their location within a chat.

Technologies used: Flutter, Dio, socket_io_client, image_picker, file_picker, location.

## Working Flow
1. Open the app -> The application makes initial API calls via Dio to authenticate the user and fetch required data.
2. Establish Connection -> The socket_io_client establishes a persistent real-time connection with the backend server.
3. Send Message -> The user inputs text and sends it. The app emits a Socket.IO event containing the message payload to the server.
4. Receive Message -> The server emits an event back. The app's Socket.IO listener catches it and updates the UI to display the new message instantly.
5. Send Attachment -> The user selects media via image_picker, a document via file_picker, or a GPS coordinate via the location package. The app uploads the data and sends a corresponding message through the socket or REST API.
