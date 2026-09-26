import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/reel_controller.dart';
import 'native_video_player.dart';
import 'reel_upload_screen.dart';

class ReelFeedScreen extends ConsumerStatefulWidget {
  const ReelFeedScreen({super.key});

  @override
  ConsumerState<ReelFeedScreen> createState() => _ReelFeedScreenState();
}

class _ReelFeedScreenState extends ConsumerState<ReelFeedScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isScreenActive = true;
  final Set<String> _likedReels = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (mounted) {
        setState(() {
          _isScreenActive = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          _isScreenActive = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reelsAsyncValue = ref.watch(reelsFeedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: reelsAsyncValue.when(
                data: (reels) {
                  if (reels.isEmpty) {
                    return const Center(
                      child: Text(
                        'No reels available',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }
                  return PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: reels.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final reel = reels[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          NativeVideoPlayerWidget(
                            url: reel.videoUrl,
                            isPlaying: _currentIndex == index && _isScreenActive,
                          ),
                          Positioned(
                            bottom: 20,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reel.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 60,
                            right: 16,
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _likedReels.contains(reel.id) ? Icons.favorite : Icons.favorite_border,
                                    color: _likedReels.contains(reel.id) ? Colors.red : Colors.white,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    final isLiked = _likedReels.contains(reel.id);
                                    setState(() {
                                      if (isLiked) {
                                        _likedReels.remove(reel.id);
                                      } else {
                                        _likedReels.add(reel.id);
                                      }
                                    });
                                    ref.read(firebaseServiceProvider).Like(reel.id, !isLiked);
                                  },
                                ),
                                Text(
                                  '${reel.likes}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading reels: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 36),
                onPressed: () async {
                  setState(() {
                    _isScreenActive = false;
                  });
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReelUploadScreen()),
                  );
                  if (mounted) {
                    setState(() {
                      _isScreenActive = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
