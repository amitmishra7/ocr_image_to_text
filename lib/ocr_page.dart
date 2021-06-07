import 'dart:io';

import 'package:flutter/material.dart';
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

  bool _saving = false;

  Future<void> extractText() async {
    if (_pickedImageFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Null Image')));
    }
    try {
      setState(() {
        _saving = true;
      });
      String _resultStringRaw = await SimpleOcrPlugin.performOCR(
          _pickedImageFile.path,
          delimiter: ' ');
      _result = ocrModelFromJson(_resultStringRaw);

      setState(() {
        _saving = false;
      });
    } catch (e) {
      print("exception on OCR operation: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('OCR')),      floatingActionButton: FloatingActionButton(
          onPressed: extractText, child: Icon(Icons.search)),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Center(
          child: ListView(
            reverse: true,
            children: [
              SizedBox(height: 50),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    child: ElevatedButton(
                      onPressed: () async {
                        _pickedImageFile = await ImagePicker()
                            .getImage(source: ImageSource.camera);
                        setState(() {});
                      },
                      child: Text('Pick From Camera'),
                    ),
                  ),
                  SizedBox(width: 20),
                  Align(
                    child: ElevatedButton(
                      onPressed: () async {
                        _pickedImageFile = await ImagePicker()
                            .getImage(source: ImageSource.gallery);
                        setState(() {});
                      },
                      child: Text('Pick From Gallery'),
                    ),
                  )
                ],
              ),
              _pickedImageFile == null
                  ? Text('Nothing Selected', textAlign: TextAlign.center)
                  : Container(
                      width: 100,
                      height: 100,
                      child: Image.file(File(_pickedImageFile.path))),
              Divider(),
              Container(
                padding: EdgeInsets.all(8.0),
                child:
                    Text(_result?.text ?? 'null', textAlign: TextAlign.center),
              )
            ],
          ),
        ),
      ),
    );
  }
}
