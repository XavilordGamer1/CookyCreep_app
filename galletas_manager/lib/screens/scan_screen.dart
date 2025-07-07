// lib/screens/scan_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/ventas_provider.dart';
import '../providers/cookie_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.code128, BarcodeFormat.ean13],
  );

  bool isProcessing = false;
  bool isTorchOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // --- MEJORA: Se añade la validación del código ---
  void _onDetect(BarcodeCapture capture) {
    if (isProcessing) return;

    final String? codigo = capture.barcodes.first.rawValue;
    if (codigo == null) return;

    // Se obtiene la lista de códigos válidos que hemos generado en la app
    final validCodes = _getValidProductCodes(context);

    // Se comprueba si el código escaneado está en nuestra lista
    if (validCodes.contains(codigo)) {
      setState(() {
        isProcessing = true;
      });
      controller.stop();
      _mostrarDialogoVenta(codigo);
    } else {
      // Si el código no es válido, se muestra un error rápido y se sigue escaneando
      // Esto evita detenerse por códigos de otros productos.
      _showInvalidCodeError();
    }
  }

  // Función auxiliar para generar la lista de códigos de producto válidos
  List<String> _getValidProductCodes(BuildContext context) {
    final cookieProvider = Provider.of<CookieProvider>(context, listen: false);
    return cookieProvider.cookies.map((cookie) {
      // Genera el código de producto exactamente como en la pantalla de "Generar Códigos"
      return "PRODUCTO-${cookie.nombre.toUpperCase().replaceAll(' ', '-')}";
    }).toList();
  }

  // Muestra un mensaje de error sin detener el flujo
  void _showInvalidCodeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Código no reconocido."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _mostrarDialogoVenta(String codigo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Venta'),
        content: Text('Código escaneado:\n$codigo'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeCamera();
            },
          ),
          ElevatedButton(
            child: const Text('De Contado'),
            onPressed: () {
              Provider.of<VentasProvider>(context, listen: false)
                  .registrarVenta(codigo);
              Navigator.of(ctx).pop();
              _showSuccessAndResume('Venta de contado registrada.');
            },
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
            child: const Text('Fiar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _mostrarDialogoFiar(codigo);
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoFiar(String codigo) {
    final deudorController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Venta Fiada'),
        content: TextField(
          controller: deudorController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del cliente'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeCamera();
            },
          ),
          ElevatedButton(
            child: const Text('Guardar Deuda'),
            onPressed: () {
              if (deudorController.text.isEmpty) return;
              Provider.of<VentasProvider>(context, listen: false)
                  .registrarVenta(
                codigo,
                esFiado: true,
                deudor: deudorController.text,
              );
              Navigator.of(ctx).pop();
              _showSuccessAndResume(
                  'Venta fiada a ${deudorController.text} registrada.');
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessAndResume(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
    _resumeCamera();
  }

  void _resumeCamera() {
    setState(() {
      isProcessing = false;
    });
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear para Vender"),
        actions: [
          IconButton(
            onPressed: () {
              controller.toggleTorch();
              setState(() {
                isTorchOn = !isTorchOn;
              });
            },
            icon: Icon(isTorchOn ? Icons.flash_off : Icons.flash_on),
            tooltip: "Linterna",
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 2,
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.7),
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                "Coloca el código bajo la línea",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
