import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_parking_app/data/account.dart';
import 'package:smart_parking_app/widget/login.dart';
import 'parkingStatus.dart';
import 'package:http/http.dart' as http;

class Info extends StatefulWidget {
  State<Info> createState() => _Info(_platNo);
  final String _platNo;
  Info(this._platNo);
}

class _Info extends State<Info> {
  List<Account> _accList = [];
  late Account _acc;
  var _name = '';
  var _phone = '';
  var _carPlatNo = '';
  var _parkingSlot = '-';
  var parkInfo = [];

  String _platNo = "";
  _Info(this._platNo);

  void initState() {
    super.initState();
    _findAcc();
    matchAcc();
    _findParkingSlot();
  }

  Future _findParkingSlot() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'parkingSlot.json');
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    for (final parking in listData.entries) {
      if (parking.value['availability'] == _platNo) {
        setState(() {
          _parkingSlot = parking.value['level'] +
              '-' +
              parking.value['area'] +
              "-" +
              parking.value['slot'];
          parkInfo = [
            parking.value['level'],
            parking.value['area'],
            parking.value['slot']
          ];
        });
      }
    }
  }

  Future _findAcc() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'accSave.json');
    final response = await http.get(url);
    print('#Debug register.dart');
    print(response.body);
    final Map<String, dynamic> listData = json.decode(response.body);
    print('#Debug register.dart');
    print(listData);

    final List<Account> _acc = [];
    for (final acc in listData.entries) {
      _acc.add(Account(
          name: acc.value['name'],
          phone: acc.value['phoneNo'],
          platNo: acc.value['platNo'],
          password: acc.value['password']));
    }
    _accList = _acc;
    await matchAcc();
  }

  Future matchAcc() async {
    for (final item in _accList) {
      _acc = item;
      await checkAcc();
    }
  }

  Future checkAcc() async {
    setState(() {
      if (_platNo == _acc.platNo) {
        _name = _acc.name;
        _phone = _acc.phone;
        _carPlatNo = _acc.platNo;
      }
    });
  }

  Future<void> _checkSlot(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ParkingStatus(
                  platNo: _platNo,
                )));
    _findParkingSlot();
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    Widget exbutton = SizedBox(
        width: 100,
        height: 30,
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoadingPage(result: parkInfo)));
              setState(() {
                _parkingSlot = '-';
              });
            },
            child: Text('Exit')));

    Widget enbutton = SizedBox(
        child: ElevatedButton(
            onPressed: () {
              _checkSlot(context);
            },
            child: Text('Entrace')));
    Widget content = const Center(
      child: CircularProgressIndicator(),
    );
    setState(() {
      if (_name.isNotEmpty) {
        content = Center(
            child: Column(children: [
          SizedBox(
            height: 300,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Name'),
                  subtitle: Text(_name),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone No'),
                  subtitle: Text(_phone),
                ),
                ListTile(
                  leading: Icon(Icons.car_rental),
                  title: Text('Car Plate No'),
                  subtitle: Text(_carPlatNo),
                ),
                ListTile(
                  leading: Icon(Icons.local_parking),
                  title: Text('Car Parking Slot'),
                  subtitle: Text(_parkingSlot),
                ),
              ],
            ),
          ),
          _parkingSlot == '-' ? enbutton : exbutton
        ]));
      }
    });

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
        body: content);
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
        'availability': 'Available'
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
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
