import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connectAndListen(Function(dynamic) onNewMessage) {
    
    socket = IO.io('https://api-whatsapp-cloud.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

  n
    socket.connect();

    socket.onConnect((_) {
      print('✅ Connected to WebSocket backend');
    });

    
    socket.on('new_message', (data) {
      print('📩 Naya Message Aaya: $data');
      onNewMessage(data); 
    });
    
    
    socket.on('message_status_update', (data) {
      print('✅ Status Update: $data');
    });

    
    socket.onDisconnect((_) => print('❌ Disconnected from WebSocket'));
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
