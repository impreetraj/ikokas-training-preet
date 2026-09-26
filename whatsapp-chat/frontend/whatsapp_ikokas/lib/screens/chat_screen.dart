import 'package:flutter/material.dart';
import '../services/whatsapp_service.dart';
import '../services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String recipientPhone;

  const ChatScreen({super.key, required this.recipientPhone});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final WhatsAppService _whatsappService = WhatsAppService();
  final SocketService _socketService = SocketService();

  List<dynamic> _messages = [];
  bool _isSending = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();

    // Socket connect aur listen karo
    _socketService.connectAndListen((data) {
      if (mounted) {
        String messageText = data['textContent'] ?? '';
        String senderPhone = data['senderPhone'] ?? '';

        // Agar message usi number se aaya hai jisse hum chat kar rahe hain
        if (senderPhone == widget.recipientPhone) {
          setState(() {
            _messages.insert(0, {
              'id': data['messageId'],
              'text': messageText,
              'isMe': false,
              'time': DateTime.now(),
              'status': data['status'],
            });
          });
        }
      }
    });

    // Listen for status updates (double ticks, blue ticks)
    _socketService.socket.on('message_status_update', (data) {
      if (mounted) {
        setState(() {
          String updatedId = data['messageId'];
          String newStatus = data['status'];
          // Find the message in our list and update its status
          for (var msg in _messages) {
            if (msg['id'] == updatedId) {
              msg['status'] = newStatus;
              break;
            }
          }
        });
      }
    });
  }

  void _loadHistory() async {
    final history = await _whatsappService.getChatHistory(
      widget.recipientPhone,
    );
    if (mounted) {
      setState(() {
        // Map history from API to local format
        // Backend returns oldest first or newest first? Usually we need newest first for reverse list
        _messages = history.reversed.map((msg) {
          return {
            'id': msg['messageId'],
            'text': msg['textContent'] ?? '',
            'isMe': msg['senderPhone'] != widget.recipientPhone,
            'time': msg['timestamp'] ?? '',
            'status': msg['status'] ?? 'sent',
          };
        }).toList();

        _isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _socketService.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _isSending = true;
      // UI me turant dikhane ke liye
      _messages.insert(0, {
        'id': tempId,
        'text': text,
        'isMe': true,
        'time': DateTime.now(),
        'status': 'sent',
      });
    });

    _messageController.clear();

    final response = await _whatsappService.sendTextMessage(
      widget.recipientPhone,
      text,
    );

    if (mounted) {
      if (response != null && response['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: ${response['error']}')),
        );
      } else if (response != null && response['data'] != null) {
        // Backend se real messageId mil gaya, update temporary ID
        setState(() {
          for (var msg in _messages) {
            if (msg['id'] == tempId) {
              msg['id'] = response['data']['messageId'];
              break;
            }
          }
        });
      }

      setState(() {
        _isSending = false;
      });
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe
                ? const Radius.circular(15)
                : const Radius.circular(0),
            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(msg['text'], style: const TextStyle(fontSize: 16)),
            ),
            if (isMe) ...[
              const SizedBox(width: 5),
              Icon(
                msg['status'] == 'read'
                    ? Icons.done_all
                    : msg['status'] == 'delivered'
                    ? Icons.done_all
                    : Icons.check,
                size: 16,
                color: msg['status'] == 'read' ? Colors.blue : Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(widget.recipientPhone, style: const TextStyle(fontSize: 18)),
          ],
        ),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoadingHistory
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF128C7E),
                      ),
                    )
                  : ListView.builder(
                      reverse: true, // Naye messages neeche aayenge
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            // Chat input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF128C7E),
                    radius: 25,
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
