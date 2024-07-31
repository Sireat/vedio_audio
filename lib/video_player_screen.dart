import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  VideoPlayerScreen({required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  Timer? _timer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration; // Get total duration
        });
        _controller.play();
        _startTimer(); // Start the timer when the video starts playing
      });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_controller.value.isPlaying) {
        setState(() {
          _currentPosition = _controller.value.position;
        });
      }
    });
  }

  void _changePlaybackSpeed(double speed) {
    _controller.setPlaybackSpeed(speed);
  }

  void _jumpForward() {
    final newPosition = _controller.value.position + Duration(seconds: 10);
    _controller.seekTo(newPosition > _totalDuration ? _totalDuration : newPosition);
  }

  void _jumpBackward() {
    final newPosition = _controller.value.position - Duration(seconds: 10);
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video/Audio Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: _toggleFullScreen,
          ),
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                    style: TextStyle(fontSize: 24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.fast_rewind),
                        onPressed: _jumpBackward,
                      ),
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_forward),
                        onPressed: _jumpForward,
                      ),
                      IconButton(
                        icon: Icon(Icons.speed),
                        onPressed: () {
                          double currentSpeed = _controller.value.playbackSpeed;
                          double newSpeed = currentSpeed == 1.0 ? 1.5 : 1.0;
                          _changePlaybackSpeed(newSpeed);
                        },
                      ),
                    ],
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
