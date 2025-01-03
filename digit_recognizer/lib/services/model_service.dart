import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'image_processing_service.dart';

class ModelService {
  late Interpreter _interpreter;

  /// Load the TFLite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/blood_sweat_tears.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  /// Predict the digit from a file
  Future<String> predictDigitFromFile(File imageFile) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      List<List<List<List<double>>>> input = ImageProcessingService.preprocessImage(imageBytes);

      // Prepare the output tensor
      var output = List.generate(1, (_) => List.filled(10, 0.0));

      // Run the model
      _interpreter.run(input, output);

      // Get the predicted digit
      double maxValue = output[0].reduce((a, b) => a > b ? a : b);
      int predictedDigit = output[0].indexWhere((value) => value == maxValue);

      return "Digit: $predictedDigit";
    } catch (e) {
      return "Error in prediction: $e";
    }
  }

  void dispose() {
    _interpreter.close();
  }
}
