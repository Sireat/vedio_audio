import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import 'cloudinary_service.dart';
import 'video_player_screen.dart';

class FileUploaderScreen extends StatefulWidget {
  @override
  _FileUploaderScreenState createState() => _FileUploaderScreenState();
}

class _FileUploaderScreenState extends State<FileUploaderScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  List<Map<String, dynamic>> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchUploadedFiles();
  }

  Future<void> _fetchUploadedFiles() async {
    try {
      final List<Map<String, dynamic>> audioFiles =
          await _cloudinaryService.fetchUploadedFiles('audio');
      final List<Map<String, dynamic>> videoFiles =
          await _cloudinaryService.fetchUploadedFiles('video');
      setState(() {
        _uploadedFiles = [...audioFiles, ...videoFiles];
      });
      print('Fetched files: $_uploadedFiles');
    } catch (e) {
      print('Failed to fetch uploaded files: $e');
      // Optionally show user feedback
    }
  }

  Future<void> _pickAndUploadFile(String resourceType) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      final File file = File(result.files.single.path!);
      try {
        final response =
            await _cloudinaryService.uploadFile(file, resourceType);
        print('File uploaded successfully: $response');
        _fetchUploadedFiles(); // Refresh the list of uploaded files
      } catch (e) {
        print('Failed to upload file: $e');
        // Optionally show user feedback
      }
    }
  }

  void _showUploadOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select File Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Upload Video'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadFile('video');
                },
              ),
              ListTile(
                title: Text('Upload Audio'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadFile('audio');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _playMedia(String url, String resourceType) {
    if (resourceType == 'video') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoPlayerScreen(url: url)),
      );
    } else if (resourceType == 'audio') {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(UrlSource(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloudinary File Uploader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showUploadOptions,
                    child: Text('Upload File'),
                  ),
                ),
                SizedBox(width: 10), // Add some spacing between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: _fetchUploadedFiles,
                    child: Text('Refresh Files'),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedFiles.length,
                itemBuilder: (context, index) {
                  final file = _uploadedFiles[index];
                  final fileType = file['resource_type'];
                  final secureUrl = file['secure_url'];
                  final publicId = file['public_id'];

                  Widget mediaIcon;
                  if (fileType == 'video') {
                    mediaIcon = Icon(Icons.videocam, size: 50.0);
                  } else if (fileType == 'audio') {
                    mediaIcon = Icon(Icons.audiotrack, size: 50.0);
                  } else {
                    mediaIcon = Image.network(secureUrl); // Default case for images
                  }

                  return Center(
                    child: ListTile(
                      title: Text(
                        publicId,
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Container(
                        width: 100.0,
                        height: 60.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: mediaIcon,
                        ),
                      ),
                      onTap: () => _playMedia(secureUrl, fileType),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
