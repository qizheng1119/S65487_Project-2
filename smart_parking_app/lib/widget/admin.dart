import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_parking_app/data/complainDetail.dart';
import 'package:http/http.dart' as http;
import 'package:smart_parking_app/widget/login.dart';

class Admin extends StatefulWidget {
  State<Admin> createState() => _AdminMain();
}

class _AdminMain extends State<Admin> {
  final screen = [History(), DoneHistory()];
  var lowerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: screen[lowerIndex],
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
                    icon: Icon(Icons.comment), label: 'Complain'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: 'History'),
              ])),
    );
  }
}

class History extends StatefulWidget {
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<ComplainDetail> allcomplain = [];
  var keyUpstate = [];
  var keyDel = [];
  var platNo = '';
  var comControll = '';
  var comType = '';

  void initState() {
    getComplain();
    super.initState();
  }

  Future getComplain() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'complainDisplay.json');
    final response = await http.get(url);

    final Map<String, dynamic> listData = json.decode(response.body);

    List<ComplainDetail> getallcomplain = [];
    for (final com in listData.entries) {
      getallcomplain.add(ComplainDetail(
          platNo: com.value['platNo'],
          complainType: com.value['complainType'],
          compControll: com.value['compControll'],
          compRep: com.value['compRep']));
    }
    listData.forEach((key, value) {
      keyUpstate.add(key);
    });
    final url2 = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'complain.json');
    final response2 = await http.get(url2);

    final Map<String, dynamic> listData2 = json.decode(response2.body);
    listData2.forEach(
      (key, value) {
        keyDel.add(key);
      },
    );
    setState(() {
      allcomplain = getallcomplain;
    });
  }

  Future<void> deleteUpdData(String updateKey, String delete) async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'complain/$delete.json');
    final update = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'complainDisplay.json');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Data with key $delete deleted successfully');
    } else {
      print('Failed to delete data. Status code: ${response.statusCode}');
    }
    final Map<String, dynamic> updateLast = {
      updateKey: {
        'platNo': platNo,
        'complainType': comType,
        "compControll": comControll,
        "compRep": 'Done'
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
    setState(() {
      getComplain();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Parking App(Admin mode)'),
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
      body: allcomplain.isEmpty
          ? Center(child: Text('No record..'))
          : ListView.builder(
              itemCount: allcomplain.length,
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
                          Icons.comment,
                          color: Colors.blue,
                        ),
                        title: Text('Complain ' + (index + 1).toString(),
                            style: TextStyle(color: Colors.blue)),
                        subtitle: Text(allcomplain[index].compControll,
                            style: TextStyle(color: Colors.blue)),
                        onTap: () {
                          platNo = allcomplain[index].platNo;
                          comType = allcomplain[index].complainType;
                          comControll = allcomplain[index].compControll;
                          allcomplain.removeAt(index);
                          deleteUpdData(keyUpstate[index], keyDel[index]);
                        },
                        trailing: Icon(
                          Icons.done,
                          color: Colors.blue,
                        )));
              }),
    );
  }
}

class DoneHistory extends StatefulWidget {
  State<DoneHistory> createState() => _DoneHistoryState();
}

class _DoneHistoryState extends State<DoneHistory> {
  List<ComplainDetail> allcomplain = [];

  void initState() {
    getComplain();
    super.initState();
  }

  Future getComplain() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'complainDisplay.json');
    final response = await http.get(url);

    final Map<String, dynamic> listData = json.decode(response.body);

    List<ComplainDetail> getallcomplain = [];
    for (final com in listData.entries) {
      if (com.value['compRep'] != '-') {
        getallcomplain.add(ComplainDetail(
            platNo: com.value['platNo'],
            complainType: com.value['complainType'],
            compControll: com.value['compControll'],
            compRep: com.value['compRep']));
      }
    }

    setState(() {
      allcomplain = getallcomplain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Parking App(Admin mode)'),
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
      body: allcomplain.isEmpty
          ? Center(child: Text('No record..'))
          : ListView.builder(
              itemCount: allcomplain.length,
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
                          Icons.comment,
                          color: Colors.blue,
                        ),
                        title: Text('Complain ' + (index + 1).toString(),
                            style: TextStyle(color: Colors.blue)),
                        subtitle: Text(allcomplain[index].compControll,
                            style: TextStyle(color: Colors.blue)),
                        trailing: Icon(
                          Icons.done,
                          color: Colors.blue,
                        )));
              }),
    );
  }
}
