import 'dart:async';
import 'dart:convert';
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
  const USBDataScreen({Key? key}) : super(key: key);

  @override
  State<USBDataScreen> createState() => _USBDataScreenState();
}

class _USBDataScreenState extends State<USBDataScreen> {
  List<UsbDevice> _devices = [];
  UsbPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  String _status = "No device connected";
  String _receivedData = "";

  List<int> _samples = [];

  @override
  void initState() {
    super.initState();
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
      _subscription = inputStream.listen((Uint8List event) {
        String decoded = utf8.decode(event);
        debugPrint("Decoded: $decoded");

        _receivedData += decoded;

        // Prevent text widget from bloating
        if (_receivedData.length > 5000) {
          _receivedData = _receivedData.substring(_receivedData.length - 5000);
        }

        List<String> tokens = decoded.split(RegExp(r'[\r\n\s]+'));
        for (String token in tokens) {
          if (token.isEmpty) continue;
          int? sample = int.tryParse(token);
          if (sample != null) {
            _samples.add(sample);
            if (_samples.length > 1000) {
              _samples.removeRange(0, _samples.length - 1000);
            }
          }
        }

        debugPrint("Current sample count: ${_samples.length}");

        setState(() {});
      });
    }
  }

  Future<void> _disconnect() async {
    await _subscription?.cancel();
    await _port?.close();
    setState(() {
      _status = "Disconnected";
      _receivedData = "";
      _samples.clear();
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
              onPressed:
              _devices.isNotEmpty ? () => _connectToDevice(_devices.first) : null,
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
                      builder: (context) => ECGScreen(samples: _samples)),
                );
              },
              child: const Text("Show ECG Screen"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_receivedData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}