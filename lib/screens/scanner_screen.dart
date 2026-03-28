import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:medscan/screens/medicine_screen.dart';
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

  // We slaan zowel de zoeknaam (kleine letters) als de echte naam (voor Firestore) op
  List<Map<String, String>> _medicineDataFromDB = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicines(); // Eerst data ophalen
    _initializeCamera(); // Dan camera starten
  }

  Future<void> _fetchMedicines() async {
    _firestoreService.getMedicines().listen((snapshot) {
      if (mounted) {
        setState(() {
          _medicineDataFromDB = snapshot.docs.map((doc) {
            return {
              'searchName': doc.data()['name'].toString().toLowerCase(),
              'realName': doc
                  .id, // De ID is de naam met hoofdletters (bijv. "Amoxicilline")
            };
          }).toList();
        });
      }
      print("Database geladen: ${_medicineDataFromDB.length} medicijnen");
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
        rotation: InputImageRotation.rotation90deg,
        format: InputImageFormat.bgra8888,
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

      String matchedRealName = "";
      bool foundMatch = false;

      // Check of een van de namen uit de DB voorkomt in de gescande tekst
      for (var med in _medicineDataFromDB) {
        String searchName = med['searchName']!;
        if (searchName.length > 3 && gescandeTekst.contains(searchName)) {
          foundMatch = true;
          matchedRealName = med['realName']!;
          break;
        }
      }

      if (foundMatch) {
        setState(() {
          _hasFoundMatch = true;
        });
        print("🔥 MATCH GEVONDEN: $matchedRealName");

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => MedicineScreen(medicineName: matchedRealName),
          ),
        );

        return;
      }
    } catch (e) {
      print("Fout bij verwerken afbeelding: $e");
    }

    await Future.delayed(const Duration(seconds: 1));
    _isProcessing = false;
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
