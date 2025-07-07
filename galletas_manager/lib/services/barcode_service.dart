// import 'dart:io';
// import 'dart:typed_data';
// import 'package:barcode/barcode.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image/image.dart' as img;

// class BarcodeService {
//   static Future<File?> generateAndSaveBarcode({
//     required String data,
//     required String filename,
//     int width = 300,
//     int height = 100,
//   }) async {
//     final status = await Permission.storage.request();
//     if (!status.isGranted) return null;

//     final bc = Barcode.code128();
//     final svg = bc.toSvg(data, width: width.toDouble(), height: height.toDouble());

//     final image = bc.toImage(
//       data,
//       width: width,
//       height: height,
//     );

//     final imageBytes = Uint8List.fromList(img.encodePng(image));
//     final dir = await getExternalStorageDirectory();
//     if (dir == null) return null;

//     final file = File("${dir.path}/$filename.png");
//     await file.writeAsBytes(imageBytes);
//     return file;
//   }
// }
