import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_parking_app/widget/mainScreen.dart';
import '../data/account.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  TextEditingController passw = TextEditingController();
  String? _passError;
  bool passVisible = false;
  bool rePassVisible = false;
  List<Account> _accList = [];
  final _formKey = GlobalKey<FormState>();
  var _name = '';
  var _phone = '';
  var _platNo = '';
  var _password = '';

  @override
  void initState() {
    passVisible = true;
    rePassVisible = true;
    _findAcc();
    super.initState();
  }

  void _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) {
          return LoadingPage(
              name: _name, phone: _phone, platNo: _platNo, password: _password);
        }),
        (Route<dynamic> route) => false,
      );
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
  }

  String? _checkPlat(String? value) {
    if (value == null || value == '') {
      return 'Car Plate No cannot be empty';
    }
    for (final item in _accList) {
      if (value == item.platNo) {
        return 'Car Plat No already register';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value == '') {
      return "Please enter your password";
    } else if (value.length < 8) {
      return "Password needs at least 8 characters";
    } else {
      return null;
    }
  }

  void _validateSamePassword(String value) {
    if (value != passw.text) {
      setState(() {
        _passError = 'Password not same';
      });
    } else {
      setState(() {
        _passError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Smart Parking App'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(40),
            child: Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                          onSaved: (value) {
                            _name = value!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name cannot be empty';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Name",
                              hintText: "Please Enter Your Name",
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      SizedBox(height: 20),
                      TextFormField(
                          onSaved: (value) {
                            _phone = value!;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone No cannot be empty';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: "Phone No",
                              hintText: "Please Enter Your Phone No",
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      SizedBox(height: 20),
                      TextFormField(
                          onSaved: (value) {
                            _platNo = value!;
                          },
                          validator: _checkPlat,
                          decoration: InputDecoration(
                              labelText: "Car Plate No",
                              hintText: "Please Enter Your Car Plate No",
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      SizedBox(height: 20),
                      TextFormField(
                          controller: passw,
                          onSaved: (value) {
                            _password = value!;
                          },
                          validator: _validatePassword,
                          obscureText: passVisible,
                          obscuringCharacter: "*",
                          decoration: InputDecoration(
                              labelText: "Password",
                              hintText:
                                  "Please enter password with at least 8 characters",
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
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      SizedBox(height: 20),
                      TextFormField(
                          validator: (value) => _passError,
                          onChanged: _validateSamePassword,
                          obscureText: rePassVisible,
                          obscuringCharacter: "*",
                          decoration: InputDecoration(
                              labelText: "Re-enter Password",
                              hintText: "Please Re-enter Your Password",
                              suffixIcon: IconButton(
                                icon: Icon(rePassVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    rePassVisible = !rePassVisible;
                                  });
                                },
                              ),
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _saveAccount();
                        },
                        child: Text('Register'),
                      ),
                    ]))));
  }
}

class LoadingPage extends StatefulWidget {
  final String name;
  final String phone;
  final String platNo;
  final String password;
  LoadingPage(
      {required this.name,
      required this.phone,
      required this.platNo,
      required this.password});

  State<LoadingPage> createState() => _LoadingPageState(
      name: name, phone: phone, platNo: platNo, password: password);
}

class _LoadingPageState extends State<LoadingPage> {
  final String name;
  final String phone;
  final String platNo;
  final String password;
  _LoadingPageState(
      {required this.name,
      required this.phone,
      required this.platNo,
      required this.password});

  @override
  void initState() {
    super.initState();
    _updateParking();
  }

  Future _updateParking() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'accSave.json');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'phoneNo': phone,
          'platNo': platNo,
          'password': password,
        }));
    print(response.body);
    print(response.statusCode);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) {
        return MainScreen(platNo);
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
