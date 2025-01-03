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
  bool _loading = false;

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
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
        
      
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                selectedImage == null
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text("No image selected"),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          selectedImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                SizedBox(height: 20),
                Text(
                  prediction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _captureImage,
                      icon: Icon(Icons.camera_alt),
                      label: Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _uploadImage,
                      icon: Icon(Icons.photo_library),
                      label: Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                if (_loading) ...[
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ]
              ],
              // [
              //   // ElevatedButton(
              //   //   onPressed: _uploadImage,
              //   //   child: const Text("Upload Image"),
              //   // ),
              //   ElevatedButton.icon(
              //     onPressed: _uploadImage,
              //     icon: Icon(Icons.camera_alt),
              //     label: Text("Camera"),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blueAccent,
              //     ),
              //   ),
              //   const SizedBox(width: 16),
              //   // ElevatedButton(
              //   //   onPressed: _captureImage,
              //   //   child: const Text("Capture Image"),
              //   // ),
              //   ElevatedButton.icon(
              //     onPressed: _captureImage,
              //     icon: Icon(Icons.photo_library),
              //     label: Text("Gallery"),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.greenAccent,
              //     ),
              //   ),
              // ],
            ),
          
        
      ),])
    );
  }
}
