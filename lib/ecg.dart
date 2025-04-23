import 'package:flutter/material.dart';

class ECGScreen extends StatefulWidget {
  final Map<String, List<int>> leadData;
  const ECGScreen({Key? key, required this.leadData}) : super(key: key);

  @override
  State<ECGScreen> createState() => _ECGScreenState();
}

class _ECGScreenState extends State<ECGScreen> with SingleTickerProviderStateMixin {
  final List<String> leadNames = [
    "I", "II", "III", "aVR", "aVL", "aVF",
    "V1", "V2", "V3", "V4", "V5", "V6"
  ];
  final TransformationController _controller = TransformationController();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2),
    )..addListener(() {
      setState(() {});
    });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double canvasWidth = 2500;
    final double rowHeight = 200;
    final double verticalSpacing = 40;
    final double canvasHeight = (rowHeight + verticalSpacing) * leadNames.length;

    return Scaffold(
      appBar: AppBar(title: const Text("ECG Visualization")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 0.5,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: CustomPaint(
                  size: Size(canvasWidth, canvasHeight),
                  painter: ECGPainter(
                    leadNames: leadNames,
                    leadData: widget.leadData,
                    canvasWidth: canvasWidth,
                    rowHeight: rowHeight,
                    verticalSpacing: verticalSpacing,
                    maxSamples: 10000,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _controller.value = Matrix4.identity(),
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
  final Map<String, List<int>> leadData;
  final double canvasWidth;
  final double rowHeight;
  final double verticalSpacing;
  final int maxSamples;

  ECGPainter({
    required this.leadNames,
    required this.leadData,
    required this.canvasWidth,
    required this.rowHeight,
    required this.verticalSpacing,
    required this.maxSamples,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawUnifiedGrid(canvas, size);

    for (int i = 0; i < leadNames.length; i++) {
      String lead = leadNames[i];
      double rowOffset = i * (rowHeight + verticalSpacing);
      double baseline = rowOffset + rowHeight / 2;

      List<int> samples = leadData[lead] ?? [];
      if (samples.isEmpty) continue;

      int startIndex = samples.length > maxSamples ? samples.length - maxSamples : 0;
      List<int> visible = samples.sublist(startIndex);

      double spacing = canvasWidth / maxSamples;

      Path path = Path();
      for (int j = 0; j < visible.length; j++) {
        double x = j * spacing;
        double y = baseline - (visible[j] - 128) * 1.2;
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      Paint wavePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, wavePaint);

      TextSpan span = TextSpan(
        text: lead,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(10, rowOffset + 10));
    }
  }

  void _drawUnifiedGrid(Canvas canvas, Size size) {
    const double smallSquare = 12.5; // Kitapla uyumlu kare boyutu
    const double bigSquare = smallSquare * 5;

    Paint smallPaint = Paint()
      ..color = Colors.red.withOpacity(0.15)
      ..strokeWidth = 0.5;
    Paint bigPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 1.2;

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}