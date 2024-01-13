import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_parking_app/widget/mainScreen.dart';
import 'package:http/http.dart' as http;

class ParkingStatus extends StatefulWidget {
  State<ParkingStatus> createState() => _ParkingStatus(platNo: platNo);
  final String platNo;
  ParkingStatus({required this.platNo});
}

class _ParkingStatus extends State<ParkingStatus> {
  final String platNo;
  _ParkingStatus({required this.platNo});

  late final Map<String, dynamic> _parking;

  var _level = ['-', '1', '2', '3'];
  var _area = ['-', 'A', 'B', 'C', 'D'];
  var _slot = ['-'];

  var _selectedLevel = '-';
  var _selectedArea = '-';
  var _selectedSlot = '-';

  void initState() {
    _findParking();
    super.initState();
  }

  Future _findParking() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'parkingSlot.json');
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    _parking = listData;
  }

  void refresh() {
    _slot = ['-'];
  }

  void _findSlot() {
    setState(() {
      for (final parking in _parking.entries) {
        if (_selectedLevel == parking.value['level']) {
          if (_selectedArea == parking.value['area']) {
            if (parking.value['availability'] == 'Available') {
              _slot.add(parking.value['slot']);
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Update Parking Status'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Level: '),
            SizedBox(
              height: 10,
            ),
            SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                    refresh();
                    _findSlot();
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  value: _selectedLevel,
                  items: [
                    for (final level in _level)
                      DropdownMenuItem(
                        value: level,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(level),
                          ],
                        ),
                      ),
                  ],
                )),
            SizedBox(
              height: 20,
            ),
            Text('Area'),
            SizedBox(
              height: 10,
            ),
            SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                  onChanged: (value) {
                    setState(() {
                      _selectedArea = value!;
                    });
                    refresh();
                    _findSlot();
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  value: _selectedArea,
                  items: [
                    for (final area in _area)
                      DropdownMenuItem(
                        value: area,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(area),
                          ],
                        ),
                      ),
                  ],
                )),
            SizedBox(
              height: 20,
            ),
            Text('Slot'),
            SizedBox(
              height: 10,
            ),
            SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                  onChanged: (value) {
                    setState(() {
                      _selectedSlot = value!;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  value: _selectedSlot,
                  items: [
                    for (final slot in _slot)
                      DropdownMenuItem(
                        value: slot,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(slot),
                          ],
                        ),
                      ),
                  ],
                )),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  var result = [
                    _selectedLevel,
                    _selectedArea,
                    _selectedSlot,
                    platNo
                  ];
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return LoadingPage(
                        result: result,
                      );
                    }),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Update'))
          ]),
        ));
  }
}

class LoadingPage extends StatefulWidget {
  final result;
  LoadingPage({required this.result});
  State<LoadingPage> createState() => _LoadingPageState(result: result);
}

class _LoadingPageState extends State<LoadingPage> {
  final result;
  _LoadingPageState({required this.result});

  @override
  void initState() {
    super.initState();
    _updateParking();
  }

  Future _updateParking() async {
    final update = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'parkingSlot.json');
    final updateResponse = await http.get(update);
    final Map<String, dynamic> findKey = json.decode(updateResponse.body);
    var _key = '';
    findKey.forEach((key, value) {
      if (value['level'] == result[0]) {
        if (value['area'] == result[1]) {
          if (value['slot'] == result[2]) {
            _key = key;
          }
        }
      }
    });
    final Map<String, dynamic> updateLast = {
      _key: {
        'level': result[0],
        'area': result[1],
        'slot': result[2],
        'availability': result[3]
      }
    };
    try {
      final response = await http.patch(
        update,
        body: json.encode(updateLast),
      );

      if (response.statusCode == 200) {
        print('Data updated successfully');
      } else {
        print('Failed to update data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating data: $error');
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) {
        return MainScreen(result[3]);
      }),
      (Route<dynamic> route) => false,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
