import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import '../services/whatsapp_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WhatsAppService _whatsappService = WhatsAppService();
  bool _isLoading = true;
  List<dynamic> _recentChats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() async {
    final chats = await _whatsappService.getChats();
    if (mounted) {
      setState(() {
        _recentChats = chats;
        _isLoading = false;
      });
    }
  }

  void _showNewChatDialog() {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Enter Phone Number',
            prefixText: '+',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = phoneController.text.trim();
              if (phone.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(recipientPhone: phone),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF128C7E)),
            child: const Text('Chat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text('whatsapp ikokas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        actions: [
          
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Recent Chats List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF128C7E)))
                : _recentChats.isEmpty
                    ? const Center(
                        child: Text(
                          'No recent chats.\nClick the button below to start a chat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recentChats.length,
                        itemBuilder: (context, index) {
                          final chat = _recentChats[index];
                          // API se jo JSON aayega uske keys use karenge
                          String name = chat['contactPhone'] ?? 'Unknown';
                          String lastMsg = chat['lastMessage'] ?? '';
                          String rawTime = chat['timestamp'] ?? '';
                          int unread = chat['unreadCount'] ?? 0;
                          
                          // Format time (simplistic)
                          String timeStr = '';
                          if (rawTime.isNotEmpty) {
                            try {
                              DateTime dt = DateTime.parse(rawTime).toLocal();
                              timeStr = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                            } catch (e) {
                              timeStr = rawTime;
                            }
                          }

                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 25,
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(timeStr, style: const TextStyle(color: Colors.green, fontSize: 12)),
                                if (unread > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unread.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  )
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(recipientPhone: name),
                                ),
                              ).then((_) {
                                // Jab chat screen se wapas aaye toh list refresh kar lein
                                _loadChats();
                              });
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      // Neeche Naya chat start karne ka Gol Button
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        backgroundColor: const Color(0xFF128C7E),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF128C7E).withOpacity(0.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF128C7E) : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
