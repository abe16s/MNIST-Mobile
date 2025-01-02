import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  /// Preprocess the image: convert to grayscale, resize, and normalize
  static List<List<List<List<double>>>> preprocessImage(Uint8List imageBytes) {
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Unable to decode image");
    }

    // Convert to grayscale
    img.Image grayImage = img.grayscale(originalImage);

    // Resize to 28x28
    img.Image resizedImage = img.copyResize(grayImage, width: 28, height: 28);

    // Normalize pixel values to [0, 1] and add batch dimension
    return [List.generate(
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
  }
}
