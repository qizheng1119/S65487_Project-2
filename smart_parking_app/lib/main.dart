import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widget/login.dart';
import 'data/parkingSlot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  void initState() {
    _parking();
    super.initState();
  }

  Future _parking() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'parkingSlot.json');
    final response = await http.get(url);
    if (response.body == 'null') {
      await ParkingSlot().parkingSlot();
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) {
        return Login();
      }),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
