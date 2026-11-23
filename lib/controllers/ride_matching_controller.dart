import 'dart:math' as math;

import 'package:routo/models/journey.dart';


String normalized(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

bool matchesJourney(Journey selected, Journey candidate, DateTime now) {
  if (!candidate.departure.isAfter(now) ||
      (selected.departure.year != candidate.departure.year ||
          selected.departure.month != candidate.departure.month ||
          selected.departure.day != candidate.departure.day) ||
      selected.departure.difference(candidate.departure).abs() >
          const Duration(hours: 1) ||
      normalized(selected.destination) != normalized(candidate.destination)) {
    return false;
  }
  if (selected.latitude != null &&
      selected.longitude != null &&
      candidate.latitude != null &&
      candidate.longitude != null) {
    return distanceBetween(
      selected.latitude!,
      selected.longitude!,
      candidate.latitude!,
      candidate.longitude!,
    ) <=
        2000;
  }
  return normalized(selected.pickup) == normalized(candidate.pickup);
}

double distanceBetween(double latA, double lonA, double latB, double lonB) {
  const radians = math.pi / 180;
  final latitude = math.sin((latB - latA) * radians / 2);
  final longitude = math.sin((lonB - lonA) * radians / 2);
  final a =
      latitude * latitude +
          math.cos(latA * radians) *
              math.cos(latB * radians) *
              longitude *
              longitude;
  return 12742000 * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
}