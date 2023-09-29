import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CropView extends StatefulWidget {
  const CropView({super.key});

  @override
  State<CropView> createState() => _CropViewState();
}

class _CropViewState extends State<CropView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;

  File? _firstCroppedImage;
  File? _secondCroppedImage;
  File? _mergedCroppedImage;

  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  Future _getImage(ImageSource source) async {
    _path = null;
    _image = null;

    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _path = pickedFile.path;
      _image = File(_path!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop View"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _getImage(ImageSource.gallery);
              },
              child: const Icon(
                Icons.photo_library_outlined,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _getImage(ImageSource.camera);
              },
              child: const Icon(
                Icons.camera,
              ),
            ),
          ),
        ],
      ),
      body: _body(),
      bottomNavigationBar: _buildButtons(),
    );
  }

  Widget _body() {
    if (_image == null) {
      return Text("Choose image");
    }
    return Center(
      child: CropImage(
        controller: controller,
        image: Image.file(_image!),
        paddingSize: 25.0,
        minimumImageSize: 20,
        alwaysMove: true,
      ),
    );
  }

  Widget _buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.rotation = CropRotation.up;
              controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              controller.aspectRatio = 1.0;
            },
          ),
          IconButton(
            icon: const Icon(Icons.aspect_ratio),
            onPressed: _aspectRatios,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
            onPressed: _rotateLeft,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
            onPressed: _rotateRight,
          ),
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
          if (_firstCroppedImage != null && _secondCroppedImage != null)
            TextButton(
              onPressed: _combine,
              child: const Text('Combine'),
            ),
          // TextButton(
          //   onPressed: _finished,
          //   child: const Text('Done'),
          // ),
        ],
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            // special case: no aspect ratio
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> _save() async {
    final ui.Image bitmap = await controller.croppedBitmap();
    var data = await bitmap.toByteData(format: ui.ImageByteFormat.png);
    var bytes = data!.buffer.asUint8List();

    /// Available in file manager
    var path = (await getExternalStorageDirectory())!.path;

    /// Hidden
    // var path = (await getApplicationDocumentsDirectory()).path;

    File newFile =
        File("$path/image_${DateTime.now().millisecondsSinceEpoch}.jpg");
    newFile.writeAsBytes(bytes);

    print("Saved file: ${newFile.path} ");

    if (_firstCroppedImage == null) {
      _firstCroppedImage = newFile;
    } else if (_secondCroppedImage == null) {
      _secondCroppedImage = newFile;
    }
    setState(() {});
  }

  Future<void> _combine() async {
    final image1 = img.decodeImage(_firstCroppedImage!.readAsBytesSync());
    final image2 = img.decodeImage(_secondCroppedImage!.readAsBytesSync());

    /// Merged vertically
    final mergedImage = img.Image(
      width: max(image1!.width, image2!.width),
      height: image1.height + image2.height,
    );
    img.compositeImage(mergedImage, image1);
    img.compositeImage(mergedImage, image2, dstY: image1.height);

    /// Merged horizontally
    // final mergedImage = img.Image(
    //   width: image1!.width + image2!.width,
    //   height: max(image1.height, image2.height),
    // );
    // img.compositeImage(mergedImage, image1);
    // img.compositeImage(mergedImage, image2, dstY: image1.height);

    var path = (await getExternalStorageDirectory())!.path;
    final file =
        File("$path/merged_${DateTime.now().millisecondsSinceEpoch}.jpg");
    file.writeAsBytesSync(img.encodeJpg(mergedImage));

    print("Combine file: ${file.path} ");
  }

  Future<void> _finished() async {
    final image = await controller.croppedImage();
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(6.0),
          titlePadding: const EdgeInsets.all(8.0),
          title: const Text('Cropped image'),
          children: [
            Text('relative: ${controller.crop}'),
            Text('pixels: ${controller.cropSize}'),
            const SizedBox(height: 5),
            image,
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
