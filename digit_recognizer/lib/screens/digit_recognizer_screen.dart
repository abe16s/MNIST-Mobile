import 'dart:io';
import 'package:flutter/material.dart';
import '../services/model_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class DigitRecognizerScreen extends StatefulWidget {
  const DigitRecognizerScreen({super.key});

  @override
  _DigitRecognizerScreenState createState() => _DigitRecognizerScreenState();
}

class _DigitRecognizerScreenState extends State<DigitRecognizerScreen> {
  final ModelService _modelService = ModelService();
  String prediction = "No Prediction";
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _modelService.loadModel();
  }

  /// Crop the selected image
  Future<File?> _cropImage(File imageFile) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        // cropStyle: CropStyle.rectangle, // Define the cropping style
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Edit Image',
          ),
        ],
      );
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      print("Error cropping image: $e");
      return null;
    }
  }


  /// Predict the digit from the image
  Future<void> _predictFromImage(File imageFile) async {
    String result = await _modelService.predictDigitFromFile(imageFile);
    setState(() {
      prediction = result;
      selectedImage = imageFile;
    });
  }

  /// Handle image upload with cropping
  Future<void> _uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File? croppedImage = await _cropImage(File(image.path));
        if (croppedImage != null) {
          await _predictFromImage(croppedImage);
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  /// Handle image capture with cropping
  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        File? croppedImage = await _cropImage(File(image.path));
        if (croppedImage != null) {
          await _predictFromImage(croppedImage);
        }
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digit Recognizer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedImage != null)
              Image.file(selectedImage!, width: 200)
            else
              const Text("No image selected"),
            const SizedBox(height: 16),
            const Text('Prediction Result:'),
            const SizedBox(height: 16),
            Text(prediction, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: const Text("Upload Image"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _captureImage,
                  child: const Text("Capture Image"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
