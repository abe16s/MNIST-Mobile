import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  static List<List<List<List<double>>>> preprocessImage(Uint8List imageBytes) {
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Unable to decode image");
    }

    // Convert to grayscale
    img.Image grayImage = img.grayscale(originalImage);

    // Apply binary thresholding
    img.Image binaryImage = img.Image.from(grayImage);
    for (int y = 0; y < binaryImage.height; y++) {
      for (int x = 0; x < binaryImage.width; x++) {
        int pixel = binaryImage.getPixel(x, y);
        int grayscaleValue = img.getLuminance(pixel);
        if (grayscaleValue > 128) {
          binaryImage.setPixel(x, y, img.getColor(255, 255, 255));
        } else {
          binaryImage.setPixel(x, y, img.getColor(0, 0, 0));
        }
      }
    }

    // Resize to fit 20x20 while preserving aspect ratio
    img.Image resizedImage = img.copyResize(binaryImage, width: 20, height: 20);

    // Add padding to center the digit in a 28x28 canvas
    img.Image paddedImage = img.Image(28, 28);
    img.fill(paddedImage, img.getColor(255, 255, 255)); // Set background to white
    int xOffset = (28 - resizedImage.width) ~/ 2;
    int yOffset = (28 - resizedImage.height) ~/ 2;
    img.drawImage(paddedImage, resizedImage, dstX: xOffset, dstY: yOffset);

    // Normalize pixel values
    return [
      List.generate(
        28,
        (y) => List.generate(
          28,
          (x) {
            int pixel = paddedImage.getPixel(x, y);
            int grayscaleValue = img.getLuminance(pixel);
            return [1.0 - (grayscaleValue / 255.0)]; // Invert: white digits on black
          },
        ),
      )
    ];
  }
}
