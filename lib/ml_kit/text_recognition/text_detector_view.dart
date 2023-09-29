import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../camera_view.dart';
import 'painters/text_detector_painter.dart';

class TextRecognizerView extends StatefulWidget {
  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  final TextRecognizer _textRecognizer = TextRecognizer();

  // TextRecognizer(script: TextRecognitionScript.chinese);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Text Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      /// ScreenMode.liveFeed
      final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      /// ScreenMode.gallery
      _text = 'Recognized text:\n\n${recognizedText.text}';
      _researchOnResult(recognizedText);
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _researchOnResult(RecognizedText recognizedText) {
    print("====> IKHWAN _researchOnResult");

    // Block -> Line -> Element -> Symbol
    for (var block in recognizedText.blocks) {
      print("====> IKHWAN block: ${block.text}");
      print("==============");
      for (var line in block.lines) {
        print("====> IKHWAN line: ${line.text}");
      }

      print("================================");

      // 1. Check based on criteria
      //    Criteria for date
      //      Has 2 "-" : Format DD-MM-YYYY or MM-DD-YYYY
      //      Has 2 "/" : Format DD/MM/YYYY or MM/DD/YYYY
      //    Criteria for amount
      //      Higher digit, but for debit card
      //      Second higher digit for cash [possibility]
      //      With "," or "."
    }
  }
}
