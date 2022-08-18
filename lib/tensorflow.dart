// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
//
// void preprocessImage({String path = 'assets/Image_1.jpg'}){
//   // Create and img processor which will resize an image
//   ImageProcessor imageProcessor = ImageProcessorBuilder()
//       .add(ResizeOp(224, 224, ResizeMethod.NEAREST_NEIGHBOUR))
//       .build();
//
//   // Create a TensorImage object from a File
//   TensorImage tensorImage = TensorImage.fromFile(File(path));
//
//   // Preprocess the image.
//   // The image for imageFile will be resized to (224, 224)
//   tensorImage = imageProcessor.process(tensorImage);
// }
//
// class Tensorflow extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity - 25,
//       margin: EdgeInsets.all(25),
//       child: Column(
//         children: [
//           ElevatedButton(
//             onPressed: preprocessImage,
//             child: Text('Download model from Firebase'),
//             style: ButtonStyle(alignment: Alignment.center),
//           )
//         ],
//       ),
//     );
//   }
// }
