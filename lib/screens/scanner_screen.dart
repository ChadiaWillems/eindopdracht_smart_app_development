import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:medscan/services/firestore_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  bool _hasFoundMatch = false;

  final FirestoreService _firestoreService = FirestoreService();
  List<String> _medicineNamesFromDB = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    // We luisteren naar de eerste 'vlaag' data die uit de stream komt
    _firestoreService.getMedicines().listen((snapshot) {
      setState(() {
        _medicineNamesFromDB = snapshot.docs.map((doc) {
          // We halen de 'name' op en maken er kleine letters van voor de match
          return doc.data()['name'].toString().toLowerCase();
        }).toList();
      });
      print("Database geladen via Service: $_medicineNamesFromDB");
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();

    // Start de beeldstroom: we scannen elk frame!
    _controller!.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _processImage(image);
      }
    });

    if (mounted) setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    if (_hasFoundMatch) return;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImageMetadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation90deg, // Voor iPhone staand
        format: InputImageFormat.bgra8888, // Standaard voor iOS
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageMetadata,
      );

      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      String gescandeTekst = recognizedText.text.toLowerCase().replaceAll(
        '\n',
        ' ',
      );
      if (gescandeTekst.trim().isNotEmpty) {
        print("Gescande tekst: $gescandeTekst");
      }

      bool foundMatch = false;
      String matchedName = "";

      for (String dbName in _medicineNamesFromDB) {
        // We checken of de naam uit je DB (minimaal 4 letters) in de gescande tekst staat
        if (dbName.length > 3 && gescandeTekst.contains(dbName)) {
          foundMatch = true;
          matchedName = dbName;
          break;
        }
      }

      if (foundMatch) {
        setState(() {
          _hasFoundMatch = true; // Stop direct met nieuwe frames verwerken
        });

        print("🔥 MATCH GEVONDEN IN DB: $matchedName");

        // Toon de popup
        _showMatchFound(matchedName);

        return; // Stop de functie hier
      }
    } catch (e) {
      print("Fout bij verwerken afbeelding: $e");
    }

    await Future.delayed(
      const Duration(seconds: 1),
    ); // Even wachten om batterij te sparen
    _isProcessing = false;
  }

  void _showMatchFound(String medicineName) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Medicijn Herkend!'),
        content: Text('Ik heb $medicineName gevonden op de strip.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Bekijk details'),
            onPressed: () {
              Navigator.pop(context); // Sluit popup
              // TODO: Navigeer naar DetailPage(name: medicineName)
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Scan opnieuw'),
            onPressed: () {
              Navigator.pop(context); // Sluit popup
              setState(() {
                _hasFoundMatch = false; // Zet de vlag weer uit
                _isProcessing = false;
              });
              // We hoeven de camera niet te herstarten,
              // want de stream loopt nog, we blokkeren hem alleen niet meer.
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Scan Strip')),
      child: Stack(
        children: [
          CameraPreview(_controller!),
          // Hier kunnen we later een mooi wit kader (overlay) overheen zetten
          Center(
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
