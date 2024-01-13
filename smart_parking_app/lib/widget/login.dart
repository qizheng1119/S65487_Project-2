import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_parking_app/widget/admin.dart';
import 'package:smart_parking_app/widget/mainScreen.dart';
import '../data/account.dart';
import 'register.dart';

class Login extends StatefulWidget {
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  bool passVisible = false;
  var _platNo = '';
  List<Account> _accList = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController _checkPlat = TextEditingController();

  @override
  void initState() {
    passVisible = true;
    _findAcc();
    super.initState();
  }

  void _checkMain() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_platNo == 'ADMIN') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Admin();
        }));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return MainScreen(_platNo);
        }));
      }
    }
  }

  Future _findAcc() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'accSave.json');
    final response = await http.get(url);

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<Account> _acc = [];
    for (final acc in listData.entries) {
      _acc.add(Account(
          name: acc.value['name'],
          phone: acc.value['phoneNo'],
          platNo: acc.value['platNo'],
          password: acc.value['password']));
    }
    _accList = _acc;
  }

  String? _findPlatNo(String? value) {
    if (value == null || value == '' || value.isEmpty) {
      return 'Please enter your Car Plate No';
    }
    for (final plat in _accList) {
      if (value == plat.platNo) {
        return null;
      }
    }
    return 'Car Plate No dont registered yet';
  }

  String? _findPassw(String? value) {
    if (value == null || value == '' || value.isEmpty) {
      return 'Please enter password';
    }
    for (final passw in _accList) {
      if (_checkPlat.text == passw.platNo) {
        if (value == passw.password) {
          return null;
        }
      }
    }
    return 'Wrong password';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text('Smart Parking App'),
              centerTitle: true,
            ),
            body: Center(
                child: Container(
                    padding: EdgeInsets.all(40),
                    height: 450,
                    child: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Log In',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                  controller: _checkPlat,
                                  onSaved: (value) {
                                    _platNo = value!;
                                  },
                                  validator: _findPlatNo,
                                  decoration: InputDecoration(
                                      labelText: "Car Plate No",
                                      hintText:
                                          "Please Enter Your Car Plate No",
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)))),
                              SizedBox(height: 20),
                              TextFormField(
                                  validator: _findPassw,
                                  obscureText: passVisible,
                                  obscuringCharacter: "*",
                                  decoration: InputDecoration(
                                      labelText: "Password",
                                      hintText: "Please Enter Your Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(passVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: () {
                                          setState(() {
                                            passVisible = !passVisible;
                                          });
                                        },
                                      ),
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)))),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _checkMain();
                                },
                                child: Text('Sign In'),
                              ),
                              RichText(
                                  text: TextSpan(
                                      style: TextStyle(color: Colors.grey),
                                      children: <TextSpan>[
                                    TextSpan(text: 'Need an account? '),
                                    TextSpan(
                                        text: 'Register',
                                        style: TextStyle(color: Colors.blue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return Register();
                                            }));
                                          })
                                  ]))
                            ]))))));
  }
}
