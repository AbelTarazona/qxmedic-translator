import 'package:universal_html/html.dart' as html;

class TextToImageGenerator {
  static void generateAndDownloadImage(String text, int index,
      {int maxWidth = 800, int fontSize = 16}) {
    // Crear canvas
    final canvas = html.CanvasElement(width: maxWidth, height: maxWidth);
    final ctx = canvas.context2D;

    // Configurar estilos
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, maxWidth, maxWidth);

    ctx.font = '${fontSize}px Arial';
    ctx.fillStyle = 'black';

    // Calcular el ancho y wrap del texto
    final List<String> lines = [];
    final words = text.split(' ');
    String currentLine = '';

    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      final metrics = ctx.measureText(testLine);

      if (metrics.width! > maxWidth - 40) {
        // 20px padding en cada lado
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      } else {
        currentLine = testLine;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    // Calcular altura necesaria
    final lineHeight = fontSize * 1.5;
    final totalHeight =
        (lines.length * lineHeight + 40).ceil(); // 20px padding arriba y abajo

    // Recrear canvas con altura correcta
    canvas.height = totalHeight;
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, maxWidth, totalHeight);

    // Dibujar texto
    ctx.font = '${fontSize}px Arial';
    ctx.fillStyle = 'black';

    var y = 20 + fontSize; // Empezar después del padding superior
    for (final line in lines) {
      ctx.fillText(line, 20, y);
      y += lineHeight as int;
    }

    // Convertir a imagen y descargar
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final dataUrl = canvas.toDataUrl('image/png');
      final anchor = html.AnchorElement()
        ..href = dataUrl
        ..download = 'pregunta_$index.png'
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
    } catch (e) {
      print('Error generando imagen: $e');
      throw Exception('Error al generar la imagen');
    }
  }
}
