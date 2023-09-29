import 'package:explore_text_recognition/ml_kit/my_recognition/regex/regex.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../camera_view.dart';
import '../text_recognition/painters/text_detector_painter.dart';

class MyRecognizerView extends StatefulWidget {
  @override
  State<MyRecognizerView> createState() => _MyRecognizerViewState();
}

class _MyRecognizerViewState extends State<MyRecognizerView> {
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
      String date = _findTransactionDate(recognizedText);
      String amount = _findTransactionAmount(recognizedText);

      _text = 'Transaction Date: $date\nTransaction Amount: $amount';
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  /// Date criteria:
  /// - It can appear at the beginning or end of the  list (mostly at the beginning)
  String _findTransactionDate(RecognizedText recognizedText) {
    print("================================");

    for (var block in recognizedText.blocks) {
      print("====> block: ${block.text}");
      for (var line in block.lines) {
        print("====> line: ${line.text}");
        var date = getDate(line.text);

        if (date != null) {
          return date;
        }
      }
    }

    return "Not Found";
  }

  String? getDate(String sample) {
    for (var regex in regexDates) {
      var convert = regex.firstMatch(sample)?.group(0);
      if (convert != null) {
        return convert;
      }
    }
    return null;
  }

  /// Amount criteria:
  ///   - It appear at the end (more than half data) of the  list
  String _findTransactionAmount(RecognizedText recognizedText) {
    print("================================");
    List<int> amounts = [];

    /// Hard case like example no 2
    for (var block in recognizedText.blocks.reversed) {
      print("====> block: ${block.text}");
      for (var line in block.lines) {
        print("====> line: ${line.text}");
        var amount = getAmount(line.text);

        if (amount != null) {
          amounts.add(amount);
        }

        if (amounts.length >= 3) {
          break;
        }
      }

      if (amounts.length >= 3) {
        break;
      }
    }

    /// 1. Debit card
    ///     - Same amount twice
    /// 2. Cash
    ///     - Check and calculate for last 3 amount
    ///     - Item, cash, kembalian
    /// 3. emoney
    ///     - Like park receipt, it shown available balance?
    /// 4. single amount
    ///     - return it
    for (var amount in amounts) {
      //todo
    }

    return "Not Found";
  }

  int? getAmount(String sample) {
    for (var regex in regexAmounts) {
      var convert = regex.firstMatch(sample)?.group(0);
      if (convert != null) {
        return int.parse(convert.replaceAll(".", "").replaceAll(",", ""));
      }
    }
    return null;
  }
}
