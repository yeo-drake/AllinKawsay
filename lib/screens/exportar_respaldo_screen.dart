import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/respaldo_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';

class ExportarRespaldoScreen extends StatefulWidget {
  const ExportarRespaldoScreen({super.key});

  @override
  State<ExportarRespaldoScreen> createState() =>
      _ExportarRespaldoScreenState();
}

class _ExportarRespaldoScreenState extends State<ExportarRespaldoScreen> {
  Map<String, int>? _conteo;
  String? _jsonGenerado;
  bool _generando = false;
  bool _copiado = false;

  @override
  void initState() {
    super.initState();
    _cargarConteo();
  }

  Future<void> _cargarConteo() async {
    try {
      final c = await RespaldoService().contarElementos();
      if (mounted) setState(() => _conteo = c);
    } catch (e) {
      debugPrint('Error contando: $e');
    }
  }

  Future<void> _generar() async {
    setState(() => _generando = true);
    try {
      final json = await RespaldoService().generarRespaldo();
      if (mounted) setState(() => _jsonGenerado = json);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _copiar() async {
    if (_jsonGenerado == null) return;
    await Clipboard.setData(ClipboardData(text: _jsonGenerado!));
    if (mounted) {
      setState(() => _copiado = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Respaldo copiado! Pegalo donde quieras.'),
          duration: Duration(seconds: 3),
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _copiado = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('EXPORTAR RESPALDO')),
      body: WatermarkOverlay(
        opacity: 0.04,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.granate.withOpacity(0.08),
                    AppColors.dorado.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.dorado.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.help_outline,
                            color: AppColors.granate, size: 14),
                      ),
                      const SizedBox(width: 10),
                      const Text('¿PARA QUÉ SIRVE?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.granate,
                              letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Genera un archivo JSON con TODAS las canciones, '
                    'eventos, recuerdos, historia y usuarios del grupo. '
                    'Guardalo como backup o para migrar a otro proyecto.',
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurface.withOpacity(0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Conteo
            if (_conteo != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.dorado.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.granate.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: AppColors.granate, size: 14),
                        ),
                        const SizedBox(width: 10),
                        const Text('CONTENIDO ACTUAL',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.granate,
                                letterSpacing: 2)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _fila(onSurface, Icons.library_music, 'Canciones',
                        _conteo!['canciones'] ?? 0),
                    _fila(onSurface, Icons.event, 'Eventos',
                        _conteo!['eventos'] ?? 0),
                    _fila(onSurface, Icons.photo_library, 'Recuerdos',
                        _conteo!['recuerdos'] ?? 0),
                    _fila(onSurface, Icons.people, 'Usuarios',
                        _conteo!['usuarios'] ?? 0),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Botón generar
            if (_jsonGenerado == null)
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _generando ? null : _generar,
                  icon: _generando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.dorado,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _generando ? 'GENERANDO...' : 'GENERAR RESPALDO',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                ),
              ),

            // Preview + copiar
            if (_jsonGenerado != null) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.negro, Color(0xFF2A2A2A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.4)),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.dorado.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle,
                              color: AppColors.dorado, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Respaldo generado',
                          style: TextStyle(
                            color: AppColors.dorado,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                AppColors.dorado.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(_jsonGenerado!.length / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(
                              color: AppColors.dorado.withOpacity(0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vista previa (primeras 300 letras):',
                      style: TextStyle(
                        color: AppColors.dorado.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _jsonGenerado!.length > 300
                            ? '${_jsonGenerado!.substring(0, 300)}...'
                            : _jsonGenerado!,
                        style: const TextStyle(
                          color: AppColors.dorado,
                          fontFamily: 'monospace',
                          fontSize: 9.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _copiado ? null : _copiar,
                  icon: Icon(_copiado ? Icons.check : Icons.copy),
                  label: Text(
                    _copiado
                        ? '¡COPIADO!'
                        : 'COPIAR AL PORTAPAPELES',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dorado.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: AppColors.granate, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Después de copiar, pegá el contenido en:\n'
                        '• Un chat tuyo de WhatsApp\n'
                        '• Google Drive → nuevo documento\n'
                        '• Gmail → borrador',
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withOpacity(0.75),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fila(Color onSurface, IconData icono, String label, int valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icono, size: 16, color: AppColors.granate),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: onSurface.withOpacity(0.85))),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$valor',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}