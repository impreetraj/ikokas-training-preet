import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connectAndListen(Function(dynamic) onNewMessage) {
    // Apne render backend ka URL daalein (Dhyan rahe aakhiri me / nahi hona chahiye)
    socket = IO.io('https://api-whatsapp-cloud.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connect karna shuru karein
    socket.connect();

    // Connection successful hone par
    socket.onConnect((_) {
      print('✅ Connected to WebSocket backend');
    });

    // Jab koi naya message aaye (Backend me jo emit event name hai wahi yaha aayega)
    socket.on('new_message', (data) {
      print('📩 Naya Message Aaya: $data');
      onNewMessage(data); // UI ko update karne ke liye callback
    });
    
    // Status update aane par (delivered/read)
    socket.on('message_status_update', (data) {
      print('✅ Status Update: $data');
    });

    // Disconnect hone par
    socket.onDisconnect((_) => print('❌ Disconnected from WebSocket'));
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
