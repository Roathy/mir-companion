import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackgroundScreen extends StatefulWidget {
  const VideoBackgroundScreen({super.key});

  @override
  VideoBackgroundScreenState createState() => VideoBackgroundScreenState();
}

class VideoBackgroundScreenState extends State<VideoBackgroundScreen> {
  late VideoPlayerController _controller;

  Uri videoUri = Uri.parse(
      'https://cdn.pixabay.com/video/2023/01/25/147898-792811387_large.mp4');

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      videoUri, // Replace with your video URL
    )..initialize().then((_) {
        _controller.setLooping(true); // Loop the video
        _controller.setVolume(0.0); // Mute the video
        _controller.play();
        setState(() {}); // Update the UI
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// **Background Video**
          _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : Container(
                  color: Colors.black,
                ), // Show black while loading

          /// **Overlay to Fade Out the Video**
          // Container(
          //   color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
          // ),

          /// **Centered Logo and Text**
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png', // Replace with your logo asset
                  height: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Company Name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
