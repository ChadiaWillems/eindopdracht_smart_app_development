import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Deze functie scant een afbeelding op tekst
  Future<String?> scanImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // We krijgen een blok tekst terug. We zetten alles naar lowercase 
    // zodat we makkelijk kunnen matchen met Firebase.
    String fullText = recognizedText.text.toLowerCase();
    
    print('Gescande tekst: $fullText');
    return fullText;
  }

  void dispose() {
    _textRecognizer.close();
  }
}