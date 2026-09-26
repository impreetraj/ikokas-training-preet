import 'package:flutter/material.dart';
import '../controllers/channel_controller.dart';
import '../models/channel_model.dart';
import 'chat_view.dart';
import 'login_view.dart';

class ChannelListView extends StatefulWidget {
  const ChannelListView({Key? key}) : super(key: key);

  @override
  State<ChannelListView> createState() => _ChannelListViewState();
}

class _ChannelListViewState extends State<ChannelListView> {
  final ChannelController _controller = ChannelController();
  List<ChannelModel> _channels = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final channels = await _controller.fetchChannels();
      setState(() {
        _channels = channels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createChannel() async {
    final nameController = TextEditingController();
    bool isPrivate = false;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Create Channel'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Channel Name'),
                  ),
                  CheckboxListTile(
                    title: const Text('Private'),
                    value: isPrivate,
                    onChanged: (val) {
                      setStateDialog(() => isPrivate = val ?? false);
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                   
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    try {
                      setState(() => _isLoading = true);
                      await _controller.createChannel(nameController.text.trim(), isPrivate);
                      await _loadChannels();
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
                      setState(() => _isLoading = false);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      }
    );
  }

  Future<void> _createGroupChat() async {
    final usersController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Group Chat (DM)'),
          content: TextField(
            controller: usersController,
            decoration: const InputDecoration(
              labelText: 'User IDs (comma separated)',
              hintText: 'e.g. U1234,U5678',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usersController.text.trim().isEmpty) return;
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  setState(() => _isLoading = true);
                  await _controller.createGroupChat(usersController.text.trim());
                  await _loadChannels();
                } catch (e) {
                  scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
                  setState(() => _isLoading = false);
                }
              },
              child: const Text('Create'),
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
        title: const Text('Channels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Create Group Chat (DM)',
            onPressed: _createGroupChat,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChannels,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _channels.length,
                  itemBuilder: (context, index) {
                    final channel = _channels[index];
                    return ListTile(
                      leading: Icon(channel.isPrivate ? Icons.lock : Icons.tag),
                      title: Text(channel.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatView(channel: channel),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChannel,
        child: const Icon(Icons.add),
      ),
    );
  }
}
