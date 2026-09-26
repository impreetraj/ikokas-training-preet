import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../controllers/reel_controller.dart';

class ReelUploadScreen extends ConsumerStatefulWidget {
  const ReelUploadScreen({super.key});

  @override
  ConsumerState<ReelUploadScreen> createState() => _ReelUploadScreenState();
}

class _ReelUploadScreenState extends ConsumerState<ReelUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  File? _selectedVideo;
  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    _titleController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
      });
      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.file(_selectedVideo!)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.setLooping(true);
          _videoPlayerController!.play();
        });
    }
  }

  void _uploadReel() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your reel')),
      );
      return;
    }
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video')),
      );
      return;
    }

    final error = await ref.read(reelControllerProvider.notifier).uploadReel(
      videoFile: _selectedVideo!,
      title: title,
    );

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reel uploaded successfully!')),
        );
        setState(() {
          _selectedVideo = null;
          _videoPlayerController?.dispose();
          _videoPlayerController = null;
          _titleController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(reelControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Reel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _selectedVideo == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library, size: 64, color: Colors.black54),
                          SizedBox(height: 12),
                          Text(
                            'Tap to select a video',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController!),
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reel Title',
                hintText: 'Enter a title...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 100,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: uploadState ? null : _uploadReel,
              icon: uploadState
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: Text(
                uploadState ? 'Uploading...' : 'Upload Reel',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
