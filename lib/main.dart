//import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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

  // void downloadModel() {
  //   FirebaseModelDownloader.instance
  //       .getModel(
  //           'mobilenetv2_classification',
  //           FirebaseModelDownloadType.localModel,
  //           FirebaseModelDownloadConditions(
  //             iosAllowsCellularAccess: true,
  //             iosAllowsBackgroundDownloading: false,
  //             androidChargingRequired: false,
  //             androidWifiRequired: false,
  //             androidDeviceIdleRequired: false,
  //           ))
  //       .then((customModel) {
  //     final localModelPath = customModel.file;
  //     print('Model downloaded! ${localModelPath as String}');
  //   });
  // }

  Future<void> loadModelFiles() async {
    String? res = await Tflite.loadModel(
        model: "assets/mobilenetv2_model.tflite",
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
        imageMean: 127.5, // defaults to 117.0
        imageStd: 1, // defaults to 1.0
        numResults: 5, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    print(recognitions);
    _textController = recognitions.toString();
    _writeData();

    if (recognitions != null) {
      recognitions.forEach((element) {
        result = element['label'];
      });
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
      saveImage();
      doImageClassification();
    });
  }

  Future<void> captureImage() async {
    XFile pickedFile =
        await imagePicker.pickImage(source: ImageSource.camera) as XFile;
    setState(() {
      _image = File(pickedFile.path);
      saveImage();
      doImageClassification();
    });
  }

  Future<void> saveImage() async {

    // var status = await Permission.storage.status;
    // while (status.isDenied) {
    //   // You can request multiple permissions at once.
    //   Map<Permission, PermissionStatus> statuses = await [
    //     Permission.storage,
    //     Permission.camera,
    //   ].request();
    //   print(statuses[Permission.storage]); // it should print PermissionStatus.granted
    // }
    //
    // Uint8List bytes = await _image.readAsBytes();
    // var result = await ImageGallerySaver.saveImage(
    //     bytes,
    //     quality: 100,
    //     name: _image.path.split('/').last
    // );
    //
    // if(result["isSuccess"] == true){
    //   print("Image saved successfully.");
    //
    //   setState(() {
    //
    //   });
    // }else{
    //   print(result["errorMessage"]);
    // }
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
      home: Scaffold(
          appBar: AppBar(
            title: Text('Showcasing TF Lite models'),
          ),
          body: Center(
            child: Column(
              children: [
                _image.path != 'NoPath'
                    ? Image.file(_image, width: 224, height: 224,)
                    : Icon(
                        Icons.image,
                        size: 100,
                      ),
                ElevatedButton(
                  onPressed: choseImageFromGallery,
                  onLongPress: captureImage,
                  child: Text('Chose or capture image'),
                ),
                Text(result),
              ],
            ),
          )),
    );
  }
}
