import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late File _image;
  late ImagePicker imagePicker;
  String result = 'Nothing';

  @override
  void initState() {
    super.initState();
    _image = File('NoPath');
    imagePicker = ImagePicker();
    loadModelFiles();
  }

  Future<void> loadModelFiles() async {
    String? res = await Tflite.loadModel(
        model: "assets/mobilenetv2_model_tutorial_v2.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  Future<void> doImageClassification() async {
    var recognitions = await Tflite.runModelOnImage(
        path: _image.path, // required
        imageMean: 117, // defaults to 117.0
        imageStd: 1, // defaults to 1.0
        numResults: 5, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    print(recognitions);
    _textController = recognitions.toString();
    _writeData();

    if (recognitions != null) {
      result = recognitions.first['label'];
      setState(() {
        result;
      });
    }
  }

  Future<void> choseImageFromGallery() async {
    XFile pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery) as XFile;
    setState(() {
      _image = File(pickedFile.path);
      doImageClassification();
    });
  }

  Future<void> captureImage() async {
    XFile pickedFile =
        await imagePicker.pickImage(source: ImageSource.camera) as XFile;
    setState(() {
      _image = File(pickedFile.path);
      doImageClassification();
    });
  }

  // Writing to text
  Future<String> get _getDirPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  late String _textController = "";

  Future<void> _writeData() async {
    final _dirPath = await _getDirPath;

    final _myFile = File('$_dirPath/data.txt');
    // If data.txt doesn't exist, it will be created automatically

    await _myFile.writeAsString(_textController);
    _textController = "";

    print('Saved to ${_dirPath}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Showcasing TF Lite model'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.deepPurpleAccent,
            bottom: PreferredSize(
                child: Container(
                  color: Colors.deepPurpleAccent,
                  height: 4.0,
                ),
                preferredSize: Size.fromHeight(4.0)),
          ),
          body: Center(
            child: Column(
              children: [
                _image.path != 'NoPath'
                    ? Image.file(
                        _image,
                        width: 224,
                        height: 224,
                      )
                    : Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.deepPurpleAccent,
                      ),
                ElevatedButton(
                  onPressed: choseImageFromGallery,
                  onLongPress: captureImage,
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent)),
                  child: Text(
                    'Chose or capture image',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Text(result, style: TextStyle(color: Colors.deepPurpleAccent),),
              ],
            ),
          )),
    );
  }
}
