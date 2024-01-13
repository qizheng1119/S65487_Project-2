import 'dart:convert';
import 'package:smart_parking_app/widget/login.dart';

import '../data/checkAvailable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Utilisation extends StatefulWidget {
  State<Utilisation> createState() => _UtilisationState();
}

class _UtilisationState extends State<Utilisation> {
  var level = ['1', '2', '3', '4'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Parking App'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return Login();
                  }),
                  (Route<dynamic> route) => false,
                );
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: ListView.builder(
          itemCount: level.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 16),
          itemBuilder: (context, index) {
            return Container(
                padding: EdgeInsets.all(10),
                child: ListTile(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10)),
                    leading: Icon(
                      Icons.local_parking,
                      color: Colors.blue,
                    ),
                    title: Text('Level', style: TextStyle(color: Colors.blue)),
                    subtitle: Text(level[index],
                        style: TextStyle(color: Colors.blue)),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Area(level: level[index])));
                    }));
          }),
    );
  }
}

class Area extends StatefulWidget {
  final String level;
  Area({required this.level});
  State<Area> createState() => _AreaState(level: level);
}

class _AreaState extends State<Area> {
  final String level;
  _AreaState({required this.level});

  var area = ['A', 'B', 'C', 'D'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Parking App'),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: area.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 16),
          itemBuilder: (context, index) {
            return Container(
                padding: EdgeInsets.all(10),
                child: ListTile(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10)),
                    leading: Icon(
                      Icons.local_parking,
                      color: Colors.blue,
                    ),
                    title: Text('Area', style: TextStyle(color: Colors.blue)),
                    subtitle:
                        Text(area[index], style: TextStyle(color: Colors.blue)),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ParkingSlot(
                                    level: level,
                                    area: area[index],
                                  )));
                    }));
          }),
    );
  }
}

class ParkingSlot extends StatefulWidget {
  final String level;
  final String area;

  ParkingSlot({required this.level, required this.area});
  State<ParkingSlot> createState() =>
      _ParkingSlotState(level: level, area: area);
}

class _ParkingSlotState extends State<ParkingSlot> {
  final String level;
  final String area;
  List<CheckParking> _slot = [];

  _ParkingSlotState({required this.level, required this.area});

  @override
  void initState() {
    super.initState();
    _findParking();
  }

  Future _findParking() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'parkingSlot.json');
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    List<CheckParking> checkSlot = [];
    setState(() {
      for (final parking in listData.entries) {
        if (level == parking.value['level']) {
          if (area == parking.value['area']) {
            checkSlot.add(CheckParking(
                slot: parking.value['level'] +
                    "-" +
                    parking.value['area'] +
                    "-" +
                    parking.value['slot'],
                available: parking.value['availability'] == 'Available'));
          }
        }
      }
      _slot = checkSlot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Parking App'),
        centerTitle: true,
      ),
      body: _slot.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _slot.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 16),
              itemBuilder: (context, index) {
                return Container(
                    padding: EdgeInsets.all(10),
                    child: ListTile(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: _slot[index].available
                                    ? Colors.blue
                                    : Colors.red),
                            borderRadius: BorderRadius.circular(10)),
                        leading: Icon(
                          Icons.local_parking,
                          color:
                              _slot[index].available ? Colors.blue : Colors.red,
                        ),
                        title: Text('Slot: ' + _slot[index].slot,
                            style: _slot[index].available
                                ? TextStyle(color: Colors.blue)
                                : TextStyle(color: Colors.red)),
                        subtitle: _slot[index].available
                            ? Text('Available',
                                style: TextStyle(color: Colors.blue))
                            : Text('Reserved',
                                style: TextStyle(color: Colors.red))));
              }),
    );
  }
}
