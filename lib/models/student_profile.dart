import 'dart:typed_data';

import 'package:routo/models/journey.dart';


class StudentProfile {
  String name = '';
  int age = 18;
  String gender = '';
  String section = '';
  Uint8List? photo;
  bool driver = false;
  String vehicle = '';
  String model = '';
  int capacity = 1;
  Journey? journey;
}