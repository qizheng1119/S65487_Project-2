import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_parking_app/data/complainDetail.dart';
import 'package:smart_parking_app/widget/login.dart';

class Complain extends StatefulWidget {
  final String platNo;
  Complain({required this.platNo});
  State<Complain> createState() => _Complain(platNo: platNo);
}

class _Complain extends State<Complain> {
  final String platNo;
  List<String> complain = ['car', 'parking', 'other'];
  String _complain = 'car';
  String comdet = '';
  final _formKey = GlobalKey<FormState>();
  TextEditingController compControll = TextEditingController();
  _Complain({required this.platNo});

  void saveComp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
          'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
          'complain.json');
      final url2 = Uri.https(
          'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
          'complainDisplay.json');
      await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'platNo': platNo,
            'complainType': _complain,
            'compControll': comdet,
          }));
      await http.post(url2,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'platNo': platNo,
            'complainType': _complain,
            'compControll': comdet,
            'compRep': "-"
          }));
      Navigator.pop(context);
    }
  }

  Future<void> _displayComplain(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Complain'),
            content: Container(
                height: 150,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 150,
                          child: DropdownButtonFormField(
                            onChanged: (value) {
                              setState(() {
                                _complain = value!;
                              });
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            value: _complain,
                            items: [
                              for (final item in complain)
                                DropdownMenuItem(
                                  value: item,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(item),
                                    ],
                                  ),
                                ),
                            ],
                          )),
                      Form(
                          key: _formKey,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Please input details';
                              }
                              return null;
                            },
                            controller: compControll,
                            decoration: InputDecoration(
                                labelText: 'Please enter your issues'),
                          ))
                    ])),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    _complain = 'car';
                    compControll.text = '';
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    comdet = compControll.text;
                    saveComp(context);
                    _complain = 'car';
                    compControll.text = '';
                  },
                  child: Text('Save'))
            ],
          );
        });
  }

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
        body: SizedBox(
            height: 300,
            width: 800,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 100,
                      width: 400,
                      child: Card(
                          shape: RoundedRectangleBorder(
                              side: new BorderSide(
                                  color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _displayComplain(context);
                                    },
                                    icon: Icon(Icons.comment)),
                                Text('Complain')
                              ]))),
                  Container(
                    height: 100,
                    width: 400,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            side:
                                new BorderSide(color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(4.0)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return History(platNo: platNo);
                                    }));
                                  },
                                  icon: Icon(Icons.history)),
                              Text('History')
                            ])),
                  )
                ])));
  }
}

class History extends StatefulWidget {
  final String platNo;
  History({required this.platNo});
  State<History> createState() => _HistoryState(platNo: platNo);
}

class _HistoryState extends State<History> {
  List<ComplainDetail> allcomplain = [];
  final String platNo;
  _HistoryState({required this.platNo});

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
      if (com.value['platNo'] == platNo) {
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
        title: Text('Smart Parking App'),
        centerTitle: true,
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
                      trailing: allcomplain[index].compRep != "-"
                          ? Text('Done', style: TextStyle(color: Colors.blue))
                          : Text('Still process',
                              style: TextStyle(color: Colors.red)),
                    ));
              }),
    );
  }
}
