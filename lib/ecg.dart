import 'package:flutter/material.dart';

class ECGScreen extends StatefulWidget {
  final List<int> samples;
  const ECGScreen({Key? key, required this.samples}) : super(key: key);

  @override
  State<ECGScreen> createState() => _ECGScreenState();
}

class _ECGScreenState extends State<ECGScreen> {
  // Define seven lead names for the display.
  final List<String> leadNames = ["I", "II", "III", "aVR", "aVL", "aVF", "V1"];
  final TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    final canvasSize = Size(1000, 320.0 * leadNames.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ECG Visualization"),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.5,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(20),
              child: CustomPaint(
                size: canvasSize,
                painter: ECGPainter(leadNames: leadNames, samples: widget.samples),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _controller.value = Matrix4.identity();
              },
              child: const Text("Reset Zoom/Pan"),
            ),
          ),
        ],
      ),
    );
  }
}

class ECGPainter extends CustomPainter {
  final List<String> leadNames;
  final List<int> samples;

  ECGPainter({required this.leadNames, required this.samples});

  @override
  void paint(Canvas canvas, Size size) {
    _drawUnifiedGrid(canvas, size);

    final double rowHeight = size.height / leadNames.length;

    for (int i = 0; i < leadNames.length; i++) {
      double rowOffset = i * rowHeight;
      double baseline = rowOffset + rowHeight / 2;

      Path path = Path();
      if (samples.isNotEmpty) {
        path.moveTo(0, baseline - (samples[0] * 0.5));
      }
      for (int j = 1; j < samples.length; j++) {
        double x = j.toDouble();
        if (x >= size.width) break;
        double y = baseline - (samples[j] * 0.5);
        path.lineTo(x, y);
      }

      Paint wavePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, wavePaint);

      TextSpan span = TextSpan(
        text: leadNames[i],
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(5, rowOffset + 10));
    }
  }

  void _drawUnifiedGrid(Canvas canvas, Size size) {
    const double smallSquare = 20;
    const double bigSquare = 100;

    Paint smallPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 1;
    Paint bigPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 2;

    for (double x = 0; x <= size.width; x += smallSquare) {
      bool isBig = (x % bigSquare == 0);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), isBig ? bigPaint : smallPaint);
    }
    for (double y = 0; y <= size.height; y += smallSquare) {
      bool isBig = (y % bigSquare == 0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), isBig ? bigPaint : smallPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ECGPainter oldDelegate) {
    return oldDelegate.samples != samples;
  }
}