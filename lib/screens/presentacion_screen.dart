import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

class PresentacionScreen extends StatefulWidget {
  final Cancion cancion;
  const PresentacionScreen({super.key, required this.cancion});

  @override
  State<PresentacionScreen> createState() => _PresentacionScreenState();
}

class _PresentacionScreenState extends State<PresentacionScreen> {
  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    return Scaffold(
      backgroundColor: AppColors.negro,
      appBar: AppBar(
        title: Text(c.titulo),
        backgroundColor: AppColors.negro,
        foregroundColor: AppColors.dorado,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Salir',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              c.titulo.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.dorado,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 2,
              ),
            ),
            if (c.autor.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  c.autor,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.dorado.withOpacity(0.7),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            if (c.tieneNumerofonia)
              VisorNumerofonia(
                estrofas: c.estrofas,
                escala: 1.4,
              )
            else if (c.tieneNumerofoniaString)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.negro,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.dorado, width: 1.5),
                ),
                child: Text(
                  c.numerofonia,
                  style: const TextStyle(
                    color: AppColors.dorado,
                    fontSize: 22,
                    height: 1.6,
                    fontFamily: 'monospace',
                  ),
                ),
              ),

            if (c.letra.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.negro,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.4)),
                ),
                child: Text(
                  c.letra,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.doradoClaro,
                    fontSize: 20,
                    height: 1.8,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}