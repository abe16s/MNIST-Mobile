import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DigitRecognizer(),
    );
  }
}

class DigitRecognizer extends StatefulWidget {
  @override
  _DigitRecognizerState createState() => _DigitRecognizerState();
}

class _DigitRecognizerState extends State<DigitRecognizer> {
  late Interpreter interpreter;
  String prediction = "No Prediction";

  @override
  void initState() {
    super.initState();
    loadModel();
    preprocessAndRecognize('assets/eight.jpg');
  }

  /// Load the TFLite model
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/best_model.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  /// Preprocess the image and make predictions
Future<void> preprocessAndRecognize(String assetPath) async {
  try {
    // Load the image as bytes
    ByteData imageData = await rootBundle.load(assetPath);
    Uint8List imageBytes = imageData.buffer.asUint8List();

    // Decode the image
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Unable to decode image");
    }

    // Convert to grayscale
    img.Image grayImage = img.grayscale(originalImage);

    // Resize to 28x28
    img.Image resizedImage = img.copyResize(grayImage, width: 28, height: 28);

    // Normalize pixel values to [0, 1] and add batch dimension
    List<List<List<List<double>>>> input = [List.generate(
      28,
      (y) => List.generate(
        28,
        (x) {
          int pixel = resizedImage.getPixel(x, y);
          int r = img.getRed(pixel);
          int g = img.getGreen(pixel);
          int b = img.getBlue(pixel);

          // Grayscale value = (0.3 * R + 0.59 * G + 0.11 * B)
          double grayscale = (0.3 * r + 0.59 * g + 0.11 * b) / 255.0;
          return [grayscale];
        },
      ),
    )];

    // Prepare the output tensor
    // var output = List.filled(10, 0.0).reshape([1, 10]);
    var output = List.generate(1, (_) => List.filled(10, 0.0));

    // Run the model
    interpreter.run(input, output);

    // Get the predicted digit
    // int predictedDigit = output[0].indexWhere((value) => value == output[0].reduce((a, b) => a > b ? a : b));
    // double maxValue = output[0].cast<double>().reduce((a, b) => a > b ? a : b);
    // int predictedDigit = output[0].indexWhere((value) => value == maxValue);

    double maxValue = output[0].reduce((a, b) => a > b ? a : b);
    int predictedDigit = output[0].indexWhere((value) => value == maxValue);

    setState(() {
      prediction = "Digit: $predictedDigit";
    });
  } catch (e) {
    print("Error in preprocessing or recognition: $e");
  }
}




  @override
  void dispose() {
    interpreter.close();
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
            Image.asset('assets/eight.jpg', width: 200),
            const Text('Prediction Result:'),
            const SizedBox(height: 16),
            Text(prediction, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
