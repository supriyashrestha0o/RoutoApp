import 'dart:math' as math;

// class Journey {
//   const Journey(
//     this.pickup,
//     this.destination,
//     this.departure,
//     this.preference, {
//     this.latitude,
//     this.longitude,
//   });
//   final String pickup;
//   final String destination;
//   final DateTime departure;
//   final String preference;
//   final double? latitude;
//   final double? longitude;
// }

// enum TripStatus { available, pending, accepted, declined, completed }
//
// class PreviewTrip {
//   PreviewTrip(
//     this.journey, {
//     required this.host,
//     required this.capacity,
//     required this.vehicle,
//     required this.freeRequest,
//     required this.mine,
//     this.fare = 0,
//   });
//   final Journey journey;
//   final String host;
//   final int capacity;
//   final String vehicle;
//   final bool freeRequest;
//   final bool mine;
//   final double fare;
//   double contribution = 0;
//   TripStatus status = TripStatus.available;
//   PreviewTrip? acceptedCarRide;
//   final Set<String> members = {};
//   final Set<String> pendingMembers = {};
//   final List<String> messages = [];
//   final List<String> comments = [];
//   int? stars;
//
//   int get seats => capacity - members.length;
//
//   bool join(String name) {
//     if (name.trim().isEmpty || seats <= 0) return false;
//     return members.add(name);
//   }
//
//   bool acceptMember(String name) {
//     if (!pendingMembers.contains(name) || !join(name)) return false;
//     pendingMembers.remove(name);
//     return true;
//   }
// }
//
// String normalized(String value) =>
//     value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
//
// bool matchesJourney(Journey selected, Journey candidate, DateTime now) {
//   if (!candidate.departure.isAfter(now) ||
//       (selected.departure.year != candidate.departure.year ||
//           selected.departure.month != candidate.departure.month ||
//           selected.departure.day != candidate.departure.day) ||
//       selected.departure.difference(candidate.departure).abs() >
//           const Duration(hours: 1) ||
//       normalized(selected.destination) != normalized(candidate.destination)) {
//     return false;
//   }
//   if (selected.latitude != null &&
//       selected.longitude != null &&
//       candidate.latitude != null &&
//       candidate.longitude != null) {
//     return distanceBetween(
//           selected.latitude!,
//           selected.longitude!,
//           candidate.latitude!,
//           candidate.longitude!,
//         ) <=
//         2000;
//   }
//   return normalized(selected.pickup) == normalized(candidate.pickup);
// }
//
// double distanceBetween(double latA, double lonA, double latB, double lonB) {
//   const radians = math.pi / 180;
//   final latitude = math.sin((latB - latA) * radians / 2);
//   final longitude = math.sin((lonB - lonA) * radians / 2);
//   final a =
//       latitude * latitude +
//       math.cos(latA * radians) *
//           math.cos(latB * radians) *
//           longitude *
//           longitude;
//   return 12742000 * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
// }
