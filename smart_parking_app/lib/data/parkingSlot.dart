import 'dart:convert';

import 'package:http/http.dart' as http;

class ParkingSlot {
  final level = ['1', '2', '3'];
  final area = ['A', 'B', 'C', 'D'];
  final slot = ['1', '2', '3', '4', '5', '6', '7', '8'];

  Future parkingSlot() async {
    final url = Uri.https(
        'smartparking-c4ef7-default-rtdb.asia-southeast1.firebasedatabase.app',
        'parkingSlot.json');
    for (final i in level) {
      for (final j in area) {
        for (final k in slot) {
          await http.post(url,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'level': i,
                'area': j,
                'slot': k,
                'availability': 'Available',
              }));
        }
      }
    }
  }
}
