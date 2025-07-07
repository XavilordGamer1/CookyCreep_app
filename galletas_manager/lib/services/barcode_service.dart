import 'package:flutter/material.dart';
import 'package:galletas_manager/screens/scan_screen.dart';
import '../services/barcode_service.dart';

// 1. Clase con el nombre corregido a "MenuCardData"
class MenuCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  MenuCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class BarcodeScreen extends StatelessWidget {
  const BarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Actualiza el tipo de la lista
    final List<MenuCardData> cardData = [
      // 3. Actualiza el nombre del constructor
      MenuCardData(
        title: 'Ver Códigos Generados',
        subtitle: 'Visualiza y gestiona los códigos de barras de tus galletas',
        icon: Icons.view_list,
        onTap: () {
          // Lógica para ver códigos generados
        },
      ),
      MenuCardData(
        title: 'Escanear Código',
        subtitle: 'Escanea un código de barras para identificar una galleta',
        icon: Icons.qr_code_scanner,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ScanScreen(),
          ));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Códigos de Barras'),
      ),
      body: ListView.builder(
        itemCount: cardData.length,
        itemBuilder: (context, index) {
          final card = cardData[index];
          return Card(
            margin: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(card.icon, size: 40, color: Colors.brown),
              title: Text(card.title),
              subtitle: Text(card.subtitle),
              onTap: card.onTap,
            ),
          );
        },
      ),
    );
  }
}

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
