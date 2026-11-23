import 'package:routo/models/journey.dart';

enum TripStatus { available, pending, accepted, declined, completed }

class PreviewTrip {
  PreviewTrip(
      this.journey, {
        required this.host,
        required this.capacity,
        required this.vehicle,
        required this.freeRequest,
        required this.mine,
        this.fare = 0,
      });
  final Journey journey;
  final String host;
  final int capacity;
  final String vehicle;
  final bool freeRequest;
  final bool mine;
  final double fare;
  double contribution = 0;
  TripStatus status = TripStatus.available;
  PreviewTrip? acceptedCarRide;
  final Set<String> members = {};
  final Set<String> pendingMembers = {};
  final List<String> messages = [];
  final List<String> comments = [];
  int? stars;

  int get seats => capacity - members.length;

  bool join(String name) {
    if (name.trim().isEmpty || seats <= 0) return false;
    return members.add(name);
  }

  bool acceptMember(String name) {
    if (!pendingMembers.contains(name) || !join(name)) return false;
    pendingMembers.remove(name);
    return true;
  }
}
