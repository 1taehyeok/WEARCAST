import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../core/api/api_client.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final File personImage;
  final String? maskUrl;
  final String personId;
  final String clothingUrl;

  const ResultScreen({
    super.key,
    required this.personImage,
    required this.maskUrl,
    required this.personId,
    required this.clothingUrl,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late VideoPlayerController _controller;
  bool _isGenerating = true;
  String? _videoUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    try {
      final result = await ref.read(apiClientProvider).generateVideo(
        personImage: widget.personImage,
        maskUrl: widget.maskUrl ?? "",
        personId: widget.personId,
      );
      setState(() {
        _videoUrl = result['video_url'];
        _isGenerating = false;
      });
      _initializeVideo();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isGenerating = false;
      });
    }
  }

  Future<void> _initializeVideo() async {
    if (_videoUrl == null) return;
    _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl!));
    try {
        await _controller.initialize();
        await _controller.setLooping(true);
        await _controller.play(); // Auto play
        setState(() {});
    } catch(e) {
        setState(() { _error = "Video playback failed: $e"; });
    }
  }

  @override
  void dispose() {
    if (_videoUrl != null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Virtual Try-On Result")),
      body: Center(
        child: _isGenerating
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Generating video..."),
                ],
              )
            : _error != null
                ? Text("Error: $_error")
                : _videoUrl != null && _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const Text("Preparing video player..."),
      ),
      floatingActionButton: !_isGenerating && _error == null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isGenerating = true;
                  _error = null;
                  _videoUrl = null;
                });
                _startGeneration();
              },
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }
}
