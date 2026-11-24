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
  String vehicleNumber = '';
  int capacity = 1;
  Journey? journey;

  // Driver verification (filled on the Verification page).
  String licenseNumber = '';
  List<String> licenseImagePaths = [];
  String citizenshipNumber = '';
  List<String> citizenshipImagePaths = [];

  /// Plain map for your backend / Firebase. Image fields are local paths:
  /// upload the files first and save the returned URLs instead.
  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'gender': gender,
    'section': section,
    'driver': driver,
    'vehicle': vehicle,
    'model': model,
    'vehicleNumber': vehicleNumber,
    'capacity': capacity,
    'pickup': journey?.pickup,
    'destination': journey?.destination,
    'departure': journey?.departure.toIso8601String(),
    'preference': journey?.preference,
    'licenseNumber': licenseNumber,
    'licenseImagePaths': licenseImagePaths,
    'citizenshipNumber': citizenshipNumber,
    'citizenshipImagePaths': citizenshipImagePaths,
  };
}
