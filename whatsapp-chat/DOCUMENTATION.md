# whatsapp_chat

This is a full-stack WhatsApp clone that integrates directly with the real WhatsApp Cloud API (provided by Meta). The frontend is built with Flutter (using standard setState for state management), and the backend is powered by Node.js, Express.js, MongoDB, and Socket.IO for real-time communication.

Unlike traditional apps that use email or passwords, this app authenticates users through their WhatsApp phone number via the WhatsApp Cloud API. Once verified, users can send and receive actual WhatsApp messages. The Flutter app uses Dio to communicate with the Node.js backend. When a user sends a message from the app, the backend forwards it to the WhatsApp Cloud API using axios, and the message is delivered to the recipient's real WhatsApp account.

The app supports various message types. Users can send text, pick images and videos using image_picker, select documents using file_picker, and even share their GPS location using the location package. The backend stores a record of all these messages in MongoDB using Mongoose, tracking the message type, media IDs, location coordinates, and delivery status (sent, delivered, read, failed).

Incoming messages are handled through a Webhook. When someone replies to the WhatsApp business number, Meta sends a POST request to the backend's webhook endpoint. The backend processes the incoming message, saves it to MongoDB, and then uses Socket.IO to push the new message in real-time to the Flutter frontend. The socket_io_client package in Flutter listens for these events and updates the chat UI instantly, providing a seamless real-time chat experience.

Technologies used: Flutter, Dio, socket_io_client, image_picker, file_picker, location, Node.js, Express.js, MongoDB, Mongoose, Socket.IO, axios, dotenv, WhatsApp Cloud API.

## Working Flow
1. Open the app -> The Login Screen appears, prompting you to enter your phone number for WhatsApp verification.
2. Enter phone number and verify -> The app authenticates you through the WhatsApp Cloud API.
3. Successful login -> The chat list screen opens, displaying your active conversations.
4. Click on a chat -> The messaging screen opens, connecting to the backend via Socket.IO for real-time updates.
5. Type text and click send -> The message is sent to the Node.js backend, which forwards it to the WhatsApp Cloud API, and the recipient receives it on their actual WhatsApp.
6. Click the attachment icon -> Options appear to share an image, video, document, or location.
7. Select an image -> The image picker opens, you choose a photo, and it is uploaded and sent via the WhatsApp API.
8. Receive a message -> The Meta webhook hits the backend, Socket.IO pushes the event to the Flutter app, and the message appears instantly in the chat UI.
