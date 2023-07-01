import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MLKit Barcode Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImagePicker imagePicker;
  File? _image;
  String result = "";

  dynamic barcodeScanner;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    barcodeScanner = BarcodeScanner(formats: formats);
  }

  pickImage(bool fromGallery) async {
    XFile? pickedFile = await imagePicker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    File image = File(pickedFile!.path);
    setState(() {
      _image = image;
      if (_image != null) {
        barcodeScanning();
      }
    });
  }

  barcodeScanning() async {
    InputImage inputImage = InputImage.fromFile(_image!);
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      final Rect? boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;

      switch (type) {
        case BarcodeType.wifi:
          BarcodeWifi? barcodeWifi = barcode.value as BarcodeWifi;
          result = "Wifi: " + barcodeWifi.password!;
          break;
        case BarcodeType.url:
          BarcodeUrl barcodeUrl = barcode.value as BarcodeUrl;
          result = "Url: " + barcodeUrl.url!;
          break;
      }
    }
    setState(() {
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(_image!)
                : Icon(
                    Icons.image,
                    size: 150,
                  ),
            ElevatedButton(
              onPressed: () {
                pickImage(true);
              },
              onLongPress: () {
                pickImage(false);
              },
              child: Text("Choose"),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              child: Text(
                '$result',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'solway',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
