import 'package:smart_parking_app/widget/parkingInfo.dart';
import 'package:smart_parking_app/widget/parkingUtilisation.dart';
import 'package:flutter/material.dart';
import 'package:smart_parking_app/widget/complain.dart';

class MainScreen extends StatefulWidget {
  final String _platNo;
  State<MainScreen> createState() => _MainScreen(_platNo);
  MainScreen(this._platNo);
}

class _MainScreen extends State<MainScreen> {
  String _platNo;
  _MainScreen(this._platNo);
  var lowerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [Info(_platNo), Utilisation(), Complain(platNo: _platNo)];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: screens[lowerIndex],
          bottomNavigationBar: BottomNavigationBar(
              onTap: (value) {
                setState(() {
                  lowerIndex = value;
                });
              },
              currentIndex: lowerIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.local_parking), label: 'Parking Status'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.car_rental), label: 'Parking Utilisation'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.comment), label: 'Complain'),
              ])),
    );
  }
}
