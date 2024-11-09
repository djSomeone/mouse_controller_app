import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Accelerometer Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AccelerometerPage(),
    );
  }
}

class AccelerometerPage extends StatefulWidget {
  @override
  _AccelerometerPageState createState() => _AccelerometerPageState();
}

class _AccelerometerPageState extends State<AccelerometerPage> {
  // Variables to store accelerometer data
  double x = 0.0, y = 0.0, z = 0.0;
  double lastX = 0.0, lastY = 0.0, lastZ = 0.0; // To store previous values
  late IO.Socket socket;

  void connectToSocket() {
    // Connect to the WebSocket server using socket.io
    socket = IO.io('http://192.168.1.7:8001', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });

    // Handle connection events
    socket.onConnect((_) {
      print('Connected to server');

      // Start listening to accelerometer events once connected
      accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          x = event.x;
          y = event.y;
          z = event.z;
        });

        // Calculate changes
        double deltaX = x - lastX;
        double deltaY = y - lastY;
        double deltaZ = z - lastZ;

        // Only send data if there is a change
        if (deltaX != 0.0 || deltaY != 0.0 || deltaZ != 0.0) {
          // Prepare data in JSON format
          Map<String, dynamic> accelerometerData = {
            'dx': deltaX,
            'dy': deltaY,
            'dz': deltaZ,
          };

          // Send data as JSON using socket.emit
          socket.emit('accelerometer_data', accelerometerData);

          // Update last values
          lastX = x;
          lastY = y;
          lastZ = z;
        }
      });
    });

    // Handle disconnection events
    socket.onDisconnect((_) => print('Disconnected from server'));

    // Handle connection errors
    socket.onError((error) => print('Connection error: $error'));
  }

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  @override
  void dispose() {
    socket.dispose(); // Clean up the socket connection when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Accelerometer Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Accelerometer Values:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'X: ${x.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Y: ${y.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Z: ${z.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
