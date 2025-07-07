// lib/widgets/barcode_widget_tile.dart

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class BarcodeWidgetTile extends StatelessWidget {
  final String data;
  final String label;

  const BarcodeWidgetTile({super.key, required this.data, required this.label});

  // --- FUNCIÓN CORREGIDA PARA SER COMPATIBLE CON TU VERSIÓN DEL PAQUETE ---
  Future<void> _saveBarcodeToGallery(
      GlobalKey key, String filename, BuildContext context) async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      try {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List pngBytes = byteData!.buffer.asUint8List();

        // --- CORRECCIÓN: Se elimina el parámetro 'albumName' que no es compatible ---
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 90,
          name: filename,
        );

        if (context.mounted && result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Guardado en la galería.")),
          );
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Error al guardar: ${result['errorMessage']}")),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error al generar la imagen: $e")));
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Permiso Requerido"),
            content: const Text(
                "Para guardar la imagen, la aplicación necesita acceso a tus fotos. Por favor, habilita el permiso en los ajustes."),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: const Text("Ir a Ajustes"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    final filename = data.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RepaintBoundary(
            key: key,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: BarcodeWidget(
                data: data,
                barcode: Barcode.code128(),
                width: 250,
                height: 80,
                drawText: false,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(data, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt),
            label: const Text("Guardar en Galería"),
            onPressed: () => _saveBarcodeToGallery(key, filename, context),
          ),
        ],
      ),
    );
  }
}
