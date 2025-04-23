import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'ecg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ECG Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const USBDataScreen(),
    );
  }
}

class USBDataScreen extends StatefulWidget {
  const USBDataScreen({super.key});

  @override
  State<USBDataScreen> createState() => _USBDataScreenState();
}

class _USBDataScreenState extends State<USBDataScreen> {
  List<UsbDevice> _devices = [];
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  String _status = "No device connected";

  final List<String> leadNames = [
    "I", "II", "III", "aVR", "aVL", "aVF",
    "V1", "V2", "V3", "V4", "V5", "V6"
  ];

  final Map<String, List<int>> _leadSamples = {};
  final List<int> _buffer = [];

  static const int bufferLimit = 10000; // Python'daki BUFFER_SIZE

  @override
  void initState() {
    super.initState();
    for (var lead in leadNames) {
      _leadSamples[lead] = [];
    }
    _listDevices();
  }

  Future<void> _listDevices() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    setState(() {
      _devices = devices;
      _status = "Found ${devices.length} device(s)";
    });
  }

  Future<void> _connectToDevice(UsbDevice device) async {
    _port = await device.create();
    bool openResult = await _port!.open();
    if (!openResult) {
      setState(() {
        _status = "Failed to open port";
      });
      return;
    }

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
      115200,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    setState(() {
      _status = "Connected to ${device.productName}";
    });

    var inputStream = _port!.inputStream;
    if (inputStream != null) {
      _subscription = inputStream.listen((Uint8List data) {
        _buffer.addAll(data);

        while (_buffer.length >= 12) {
          final oneSet = _buffer.sublist(0, 12);
          _buffer.removeRange(0, 12);

          for (int i = 0; i < 12; i++) {
            final lead = leadNames[i];
            final value = oneSet[i];

            final samples = _leadSamples[lead];
            if (samples != null) {
              samples.add(value);
              if (samples.length > bufferLimit) {
                samples.removeRange(0, samples.length - bufferLimit);
              }
            }
          }
        }

        // Ekranı sürekli güncelle, tıpkı Python'daki animasyon gibi
        setState(() {});
      });
    }
  }

  Future<void> _disconnect() async {
    await _subscription?.cancel();
    await _port?.close();
    setState(() {
      _status = "Disconnected";
      _buffer.clear();
      for (var lead in leadNames) {
        _leadSamples[lead]?.clear();
      }
    });
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Data for ECG'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _devices.isNotEmpty
                  ? () => _connectToDevice(_devices.first)
                  : null,
              child: const Text("Connect to First Device"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _disconnect,
              child: const Text("Disconnect"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ECGScreen(leadData: Map.from(_leadSamples)),
                  ),
                );
              },
              child: const Text("Show ECG Screen"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: leadNames
                    .map((lead) => Text(
                    "$lead: ${_leadSamples[lead]?.length ?? 0} samples"))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}