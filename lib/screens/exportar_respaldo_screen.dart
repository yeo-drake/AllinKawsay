import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/respaldo_service.dart';
import '../theme/colors.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('EXPORTAR RESPALDO')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.granate),
                      const SizedBox(width: 8),
                      const Text(
                        '¿Para qué sirve?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.granate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Genera un archivo JSON con TODAS las canciones, '
                    'eventos, recuerdos, historia y usuarios del grupo. '
                    'Guardalo como backup o para migrar a otro proyecto.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.negro.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Conteo
          if (_conteo != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contenido actual',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.granate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _fila('Canciones', _conteo!['canciones'] ?? 0),
                    _fila('Eventos', _conteo!['eventos'] ?? 0),
                    _fila('Recuerdos', _conteo!['recuerdos'] ?? 0),
                    _fila('Usuarios', _conteo!['usuarios'] ?? 0),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Botón generar
          if (_jsonGenerado == null)
            SizedBox(
              height: 52,
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
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Preview + copiar
          if (_jsonGenerado != null) ...[
            Card(
              color: AppColors.negro,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.dorado, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Respaldo generado',
                          style: TextStyle(
                            color: AppColors.dorado,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(_jsonGenerado!.length / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(
                            color: AppColors.dorado.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vista previa (primeras 300 letras):',
                      style: TextStyle(
                        color: AppColors.dorado.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _jsonGenerado!.length > 300
                            ? '${_jsonGenerado!.substring(0, 300)}...'
                            : _jsonGenerado!,
                        style: const TextStyle(
                          color: AppColors.dorado,
                          fontFamily: 'monospace',
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _copiado ? null : _copiar,
                icon: Icon(_copiado ? Icons.check : Icons.copy),
                label: Text(
                  _copiado
                      ? '¡COPIADO!'
                      : 'COPIAR AL PORTAPAPELES',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '💡 Después de copiar, pegá el contenido en:\n'
                  '• Un chat tuyo de WhatsApp (queda guardado)\n'
                  '• Google Drive → nuevo documento\n'
                  '• Gmail → borrador\n\n'
                  'Ese texto es tu respaldo. Guardalo bien.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.negro.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _fila(String label, int valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '$valor',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
            ),
          ),
        ],
      ),
    );
  }
}