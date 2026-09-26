import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'video_player_widget.dart';
import 'audio_player_widget.dart';
import '../models/channel_model.dart';
import '../models/message_model.dart';
import '../controllers/chat_controller.dart';
import '../controllers/channel_controller.dart';
import '../services/slack_api_service.dart';
import 'dart:typed_data';

class ChatView extends StatefulWidget {
  final ChannelModel channel;
  const ChatView({Key? key, required this.channel}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController _chatController = ChatController();
  final ChannelController _channelController = ChannelController();
  final TextEditingController _messageController = TextEditingController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  String? _error;
  String? _editingMessageId;
  MessageModel? _editingMessage;
  
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _hasText = false;
  bool _isRecordingIntent = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (_hasText != hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final messages = await _chatController.fetchMessages(widget.channel.id);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editingMessage != null) {
        await _chatController.updateMessage(widget.channel.id, _editingMessageId!, text);
        _cancelEditing();
      } else {
        await _chatController.sendMessage(widget.channel.id, text);
      }
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        
        if (!_isRecordingIntent) {
          // User released the button before we finished starting
          await _audioRecorder.stop();
          return;
        }

        if (mounted) {
          setState(() {
            _isRecording = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission denied.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start recording: $e')));
      }
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      
      if (path != null) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(const SnackBar(content: Text('Uploading voice note...')));
          final file = File(path);
          if (await file.exists()) {
            final fileName = path.split('/').last;
            await _chatController.uploadFile(widget.channel.id, file.path, fileName);
            await _loadMessages();
            messenger.showSnackBar(const SnackBar(content: Text('Voice note sent!')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send recording: $e')));
      }
    }
  }

  Future<void> _cancelRecording() async {
    await _audioRecorder.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _startEditing(MessageModel message) {
    setState(() {
      _editingMessage = message;
      _editingMessageId = message.ts;
      _messageController.text = message.text;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }



  void _deleteMessage(MessageModel message) async {
    try {
      setState(() => _isLoading = true);
      await _chatController.deleteMessage(widget.channel.id, message.ts);
      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMedia(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      _uploadFile(image.path, image.name);
    }
  }

  Future<void> _handleFile() async {
    final PlatformFile? result = await FilePicker.pickFile();
    if (result != null && result.path != null) {
      _uploadFile(result.path!, result.name);
    }
  }

  Future<void> _handleAudio() async {
    final PlatformFile? result = await FilePicker.pickFile(type: FileType.audio);
    if (result != null && result.path != null) {
      _uploadFile(result.path!, result.name);
    }
  }

  Future<void> _handleVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _uploadFile(video.path, video.name);
    }
  }

  Future<void> _uploadFile(String path, String filename) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Uploading file...')));
    try {
      await _chatController.uploadFile(widget.channel.id, path, filename);
      await _loadMessages();
      messenger.showSnackBar(const SnackBar(content: Text('File uploaded successfully!')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _handleLocation() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Fetching location...')));
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _chatController.sendLocation(widget.channel.id, position.latitude, position.longitude);
      await _loadMessages();
      messenger.showSnackBar(const SnackBar(content: Text('Location shared successfully!')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Location failed: $e')));
    }
  }

  Future<void> _handleContact() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null && mounted) {
          if (contact.phones.isNotEmpty) {
            await _chatController.sendContact(
              widget.channel.id, 
              contact.displayName, 
              contact.phones.first.number
            );
            await _loadMessages();
            messenger.showSnackBar(const SnackBar(content: Text('Contact shared successfully!')));
          } else {
            messenger.showSnackBar(const SnackBar(content: Text('Contact has no phone number')));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Contact permission denied. Please allow it in settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Contact failed: $e')));
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _handleMedia(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _handleMedia(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () {
                  Navigator.pop(context);
                  _handleVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Document'),
                onTap: () {
                  Navigator.pop(context);
                  _handleFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text('Audio'),
                onTap: () {
                  Navigator.pop(context);
                  _handleAudio();
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location'),
                onTap: () {
                  Navigator.pop(context);
                  _handleLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_phone),
                title: const Text('Contact'),
                onTap: () {
                  Navigator.pop(context);
                  _handleContact();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _inviteUserDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite User'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'User ID (e.g. U12345)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _channelController.inviteUser(widget.channel.id, controller.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User invited successfully!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Invite'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.channel.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _inviteUserDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : ListView.builder(
                          reverse: true, // Reversed so newest messages appear at the bottom like a standard chat
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message.text.isNotEmpty) 
                                    if (message.text.contains('*Current Location*') && message.text.contains('google.com/maps'))
                                      // Render Map nicely
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.location_on, color: Colors.green),
                                                SizedBox(width: 8),
                                                Text('Shared Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                // Extract URL between < and >
                                                final RegExp urlRegExp = RegExp(r'<(https://www\.google\.com/maps/.*?)>');
                                                final match = urlRegExp.firstMatch(message.text);
                                                if (match != null) {
                                                  final url = match.group(1)!.replaceAll('&amp;', '&');
                                                  final uri = Uri.parse(url);
                                                  if (await canLaunchUrl(uri)) {
                                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                  }
                                                }
                                              },
                                              icon: const Icon(Icons.map),
                                              label: const Text('Open in Google Maps'),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (message.text.contains('*Contact Shared*'))
                                      Builder(
                                        builder: (context) {
                                          String name = 'Unknown';
                                          String phone = 'Unknown';
                                          String rawPhoneToDial = '';
                                          
                                          final lines = message.text.split('\n');
                                          for (var line in lines) {
                                            if (line.contains('*Name:*')) {
                                              name = line.split('*Name:*').last.trim();
                                            } else if (line.contains('*Phone:*')) {
                                              String p = line.split('*Phone:*').last.trim();
                                              if (p.startsWith('<tel:')) {
                                                final parts = p.substring(5, p.length - 1).split('|');
                                                if (parts.length == 2) {
                                                  rawPhoneToDial = parts[0];
                                                  phone = parts[1];
                                                } else {
                                                  phone = parts[0];
                                                  rawPhoneToDial = phone;
                                                }
                                              } else {
                                                phone = p;
                                                rawPhoneToDial = p;
                                              }
                                            }
                                          }
                                          
                                          return Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.blue.shade200),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Row(
                                                  children: [
                                                    Icon(Icons.contact_phone, color: Colors.blue),
                                                    SizedBox(width: 8),
                                                    Text('Shared Contact', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                const SizedBox(height: 4),
                                                Text(phone, style: TextStyle(color: Colors.grey.shade700)),
                                                const SizedBox(height: 12),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      final uri = Uri.parse('tel:$rawPhoneToDial');
                                                      if (await canLaunchUrl(uri)) {
                                                        await launchUrl(uri);
                                                      }
                                                    },
                                                    icon: const Icon(Icons.call),
                                                    label: const Text('Call Now'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue, 
                                                      foregroundColor: Colors.white,
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      )
                                    else
                                      Text(message.text),
                                  if (message.attachments.isNotEmpty)
                                    ...message.attachments.map((attachment) {
                                      if (attachment.isImage) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: FutureBuilder<Uint8List>(
                                            future: SlackApiService().downloadFileBytes(attachment.url),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                                                if (snapshot.hasError) return Text('Image error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                                                if (!snapshot.hasData) return const Text('Image failed to load', style: TextStyle(color: Colors.red));
                                                return Image.memory(snapshot.data!, height: 150, fit: BoxFit.cover);
                                              }
                                          )
                                        );
                                      } else if (attachment.isVideo) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            height: 250,
                                            width: MediaQuery.of(context).size.width * 0.7,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: VideoPlayerWidget(
                                              videoUrl: attachment.url, 
                                              botToken: SlackApiService().accessToken ?? '',
                                            ),
                                          ),
                                        );
                                      } else if (attachment.isAudio) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: AudioPlayerWidget(
                                            audioUrl: attachment.url, 
                                            botToken: SlackApiService().accessToken ?? '',
                                          ),
                                        );
                                      } else {
                                        // WhatsApp style File UI
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: InkWell(
                                            onTap: () async {
                                              final uri = Uri.parse(attachment.permalink);
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.redAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.insert_drive_file, color: Colors.white),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          attachment.name, 
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        const Text('Tap to view / download', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }).toList(),
                                ],
                              ),
                              subtitle: Text('User: ${message.user}'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _startEditing(message);
                                  } else if (value == 'delete') {
                                    _deleteMessage(message);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _isRecording ? null : _showAttachmentMenu,
                  ),
                  if (_editingMessage != null)
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: _cancelEditing,
                      color: Colors.red,
                    ),
                  Expanded(
                    child: _isRecording
                        ? Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.mic, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Recording...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: _editingMessage != null ? 'Edit message...' : 'Type a message...',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  if (_isRecording)
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.grey,
                      onPressed: _cancelRecording,
                    ),
                  GestureDetector(
                    onTap: () {
                      if (_hasText || _editingMessage != null) {
                        _sendMessage();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hold to record, release to send')));
                      }
                    },
                    onLongPressStart: (details) {
                      if (!_hasText && _editingMessage == null) {
                        _isRecordingIntent = true;
                        _startRecording();
                      }
                    },
                    onLongPressEnd: (details) {
                      if (!_hasText && _editingMessage == null) {
                        _isRecordingIntent = false;
                        _stopRecordingAndSend();
                      }
                    },
                    onLongPressCancel: () {
                      if (!_hasText && _editingMessage == null) {
                        _isRecordingIntent = false;
                        _cancelRecording();
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      radius: 24,
                      child: Icon(
                        _isRecording 
                            ? Icons.mic 
                            : (_hasText || _editingMessage != null ? Icons.send : Icons.mic),
                        color: Colors.white,
                      ),
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
