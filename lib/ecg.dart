import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  late final AnimationController _animationController;
  double scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
      setState(() {
        scrollOffset += 1.2;
      });
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
    final double canvasWidth = 10000;
    final double rowHeight = 200;
    final double verticalSpacing = 40;
    final double canvasHeight = (rowHeight + verticalSpacing) * leadNames.length;

    return Scaffold(
      appBar: AppBar(title: const Text("ECG Visualization")),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              minScale: 1,
              maxScale: 1,
              child: CustomPaint(
                size: Size(canvasWidth, canvasHeight),
                painter: ECGPainter(
                  leadNames: leadNames,
                  leadData: widget.leadData,
                  canvasWidth: canvasWidth,
                  rowHeight: rowHeight,
                  verticalSpacing: verticalSpacing,
                  maxSamples: 10000,
                  scrollOffset: scrollOffset,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => setState(() => scrollOffset = 0.0),
              child: const Text("Reset View"),
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
  final double scrollOffset;

  ECGPainter({
    required this.leadNames,
    required this.leadData,
    required this.canvasWidth,
    required this.rowHeight,
    required this.verticalSpacing,
    required this.maxSamples,
    required this.scrollOffset,
  });

  // Simple 3-point moving average filter
  List<double> smoothSamples(List<int> rawSamples) {
    if (rawSamples.length < 3) {
      return rawSamples.map((e) => e.toDouble()).toList();
    }

    List<double> smoothed = [];
    for (int i = 1; i < rawSamples.length - 1; i++) {
      double avg = (rawSamples[i - 1] + rawSamples[i] + rawSamples[i + 1]) / 3.0;
      smoothed.add(avg);
    }
    return smoothed;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawUnifiedGrid(canvas, size);

    const double scaleFactor = 0.8;

    for (int i = 0; i < leadNames.length; i++) {
      String lead = leadNames[i];
      double rowOffset = i * (rowHeight + verticalSpacing);
      double baseline = rowOffset + rowHeight / 2;

      List<int> samples = leadData[lead] ?? [];
      if (samples.length < 3) continue;

      int startIndex = samples.length > maxSamples ? samples.length - maxSamples : 0;
      List<int> visibleRaw = samples.sublist(startIndex);
      List<double> visible = smoothSamples(visibleRaw);

      double spacing = canvasWidth / maxSamples;

      Path path = Path();
      for (int j = 0; j < visible.length; j++) {
        double x = j * spacing - scrollOffset;
        double y = baseline + (visible[j] - 128) * scaleFactor;
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
    const double smallSquare = 12.5;
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
