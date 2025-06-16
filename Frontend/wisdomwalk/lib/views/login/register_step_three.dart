import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class RegisterStepThree extends StatefulWidget {
  final Function(Map<String, String>) onComplete;
  final VoidCallback onBack;

  const RegisterStepThree({
    Key? key,
    required this.onComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  State<RegisterStepThree> createState() => _RegisterStepThreeState();
}

class _RegisterStepThreeState extends State<RegisterStepThree> {
  final ImagePicker _picker = ImagePicker();
  String? _idImagePath;
  String? _faceImagePath;
  Uint8List? _idImageBytes;
  Uint8List? _faceImageBytes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please upload your ID and a selfie for verification',
              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 30),
            _buildIdUploadSection(),
            const SizedBox(height: 30),
            _buildSelfieUploadSection(),
            const SizedBox(height: 20),
            _buildPrivacyNote(),
            const SizedBox(height: 40),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ID Document',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload a photo of your ID card, passport, or driver\'s license',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _pickIdImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E1E5).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E2DB), width: 1),
            ),
            child: _buildImageDisplay(
              _idImagePath,
              _idImageBytes,
              'Tap to upload ID',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelfieUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selfie Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Take a clear photo of your face for verification',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _pickSelfieImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE6E1F5).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E2DB), width: 1),
            ),
            child: _buildImageDisplay(
              _faceImagePath,
              _faceImageBytes,
              'Tap to take a selfie',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageDisplay(
    String? imagePath,
    Uint8List? imageBytes,
    String placeholder,
  ) {
    if (kIsWeb && imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(imageBytes, fit: BoxFit.cover),
      );
    } else if (!kIsWeb && imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(File(imagePath), fit: BoxFit.cover),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            placeholder.contains('selfie')
                ? Icons.face_outlined
                : Icons.add_photo_alternate_outlined,
            size: 50,
            color: const Color(0xFFD4A017),
          ),
          const SizedBox(height: 8),
          Text(
            placeholder,
            style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
        ],
      );
    }
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E2DB), width: 1),
      ),
      child: Column(
        children: const [
          Row(
            children: [
              Icon(Icons.security, color: Color(0xFFD4A017), size: 20),
              SizedBox(width: 8),
              Text(
                'Privacy & Security',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Your ID and selfie are used only for verification purposes. WisdomWalk is committed to protecting your privacy and will not share your information with third parties.',
            style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    bool hasImages =
        kIsWeb
            ? (_idImageBytes != null && _faceImageBytes != null)
            : (_idImagePath != null && _faceImagePath != null);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4A017)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, color: Color(0xFFD4A017)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: hasImages ? _completeRegistration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A017),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                disabledBackgroundColor: const Color(
                  0xFFD4A017,
                ).withOpacity(0.5),
              ),
              child: const Text(
                'Complete',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickIdImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _idImagePath = image.path;
      });

      // For web, also store the bytes
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _idImageBytes = bytes;
        });
      }
    }
  }

  Future<void> _pickSelfieImage() async {
    final XFile? image = await _picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _faceImagePath = image.path;
      });

      // For web, also store the bytes
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _faceImageBytes = bytes;
        });
      }
    }
  }

  void _completeRegistration() {
    bool hasImages =
        kIsWeb
            ? (_idImageBytes != null && _faceImageBytes != null)
            : (_idImagePath != null && _faceImagePath != null);

    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both ID and selfie photos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For web, we'll pass the bytes as base64 strings or handle differently
    // For mobile, we pass the file paths
    Map<String, String> data = {};

    if (kIsWeb) {
      // In a real app, you'd convert bytes to base64 or upload to server
      data['idImageBytes'] = _idImageBytes.toString();
      data['faceImageBytes'] = _faceImageBytes.toString();
    } else {
      data['idImagePath'] = _idImagePath!;
      data['faceImagePath'] = _faceImagePath!;
    }

    widget.onComplete(data);
  }
}
