import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';

import 'ocr_model.dart';

class OCRPage extends StatefulWidget {
  @override
  _OCRPageState createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  OcrModel _result;
  PickedFile _pickedImageFile;
  File _imageFile;
  TextEditingController _editTextController;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(title: Text('OCR'));
    var _mediaQuery = MediaQuery.of(context);
    var _heightOfScreen = _mediaQuery.size.height -
        appBar.preferredSize.height -
        _mediaQuery.padding.top -
        _mediaQuery.padding.bottom;



    return Scaffold(
      appBar: appBar,
      floatingActionButton: _floatingActionButtons(),
    
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _imageFile == null ? SizedBox(height: 300) : Container(),
              _imageFile == null
                  ? Center(
                      child: Text(
                        'No Images Chosen',
                        style: TextStyle(fontSize: 24),
                      ),
                    )
                  : Container(
                      height: _heightOfScreen,
                      width: _mediaQuery.size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                      child: Image.file(_imageFile)),
            ],
          ),
        ),
      ),
    );
  }
/// FloatingActionButtons according to image null status
  Column _floatingActionButtons() {
    return _imageFile != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () => setState(() {
                        _imageFile = null;
                      }),
                  label: Text('Close'),
                  icon: Icon(Icons.close)),
              SizedBox(height: 16),
              FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () => _cropImage().then((_) => setState(() {})),
                  label: Text('Crop'),
                  icon: Icon(Icons.crop)),
              SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: null,
                onPressed: extractText,
                label: Text('Scan'),
                icon: Icon(Icons.search),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () async {
                    _pickedImageFile = await ImagePicker()
                        .getImage(source: ImageSource.gallery);
                    if (_pickedImageFile != null) {
                      _imageFile = File(_pickedImageFile.path);
                    }
                    setState(() {});
                  },
                  label: Text('Gallery'),
                  icon: Icon(Icons.photo)),
              SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: null,
                onPressed: () async {
                  _pickedImageFile =
                      await ImagePicker().getImage(source: ImageSource.camera);
                  if (_pickedImageFile != null) {
                      _imageFile = File(_pickedImageFile.path);
                    }
                  setState(() {});
                },
                label: Text('Camera'),
                icon: Icon(Icons.camera_alt),
              ),
            ],
          );
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _pickedImageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _imageFile = croppedFile;
    }
  }

  Future<Null> extractText() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No Image Found!')));
      return;
    }
    try {

      // Model progress HUD start 
      setState(() {
        _saving = true;
      });

      String _result =
          await SimpleOcrPlugin.performOCR(_imageFile.path);
      //converting raw string to json creates problem if image has double quotes in text.
      // _result = ocrModelFromJson(_resultStringRaw);

      // Model progress HUD stop
      setState(() {
        _saving = false;
      });
      //Inititalizes dialog box with result string.
      _editTextController = TextEditingController(text: _result);
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Scanned Text'),
              actions: [
                TextButton(
                    onPressed: () => Share.share(_result),
                    child: Text('Share'))
              ],
              content: TextField(
                  decoration: InputDecoration(border: InputBorder.none),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _editTextController),
            );
          });
    } on FormatException {
      print(_result);
    } catch (e) {
      print("exception on OCR operation: ${e.toString()}");
    }
  }
}

class OcrPageButton extends StatelessWidget {
  final onPressed;

  final text;

  const OcrPageButton({@required this.onPressed, @required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xff48AA8B)),
          minimumSize: MaterialStateProperty.all(Size(20, 50))),
      child: Text(text),
    );
  }
}
