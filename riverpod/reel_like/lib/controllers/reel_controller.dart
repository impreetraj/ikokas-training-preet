import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reel_model.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';

final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());
final firebaseServiceProvider = Provider((ref) => FirebaseService());

final reelsFeedProvider = StreamProvider<List<ReelModel>>((ref) {
  return ref.read(firebaseServiceProvider).getReels();
});

class ReelController extends Notifier<bool> {
  @override
  bool build() {
    return false; 
  }

  Future<String?> uploadReel({required File videoFile, required String title}) async {
    state = true; 

    try {
      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);

      
      final videoUrl = await cloudinaryService.uploadVideo(videoFile);
      if (videoUrl == null) {
        state = false;
        return 'Failed to upload video to Cloudinary';
      }

      
      final newReelId = DateTime.now().millisecondsSinceEpoch.toString();
      final reel = ReelModel(
        id: newReelId,
        title: title,
        videoUrl: videoUrl,
        createdAt: DateTime.now(),
      );

      await firebaseService.saveReel(reel);
      
      state = false;
      return null; // Success
    } catch (e) {
      state = false;
      return 'An error occurred during upload: $e';
    }
  }
}

final reelControllerProvider = NotifierProvider<ReelController, bool>(ReelController.new);
