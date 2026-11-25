import '../lib/ride_model.dart';

// import 'package:routo/controllers/ride_matching_controller.dart';
// import 'package:routo/models/journey.dart';
// import 'package:routo/models/preview_trip.dart';

void check(bool result, String description) {
  if (!result) throw StateError(description);
  print('PASS $description');
}

void main() {
  final now = DateTime(2026, 11, 19, 6);
  final departure = now.add(const Duration(hours: 1));
  final selected = Journey('Dhumbarahi', 'PCPS College', departure, 'Everyone');
  check(
    matchesJourney(
      selected,
      Journey(
        ' dhumbarahi ',
        'pcps   college',
        departure.add(const Duration(minutes: 35)),
        'Everyone',
      ),
      now,
    ),
    'same route and date with 35-minute difference',
  );
  check(
    !matchesJourney(
      selected,
      Journey('Kalanki', 'PCPS College', departure, 'Everyone'),
      now,
    ),
    'unrelated pickup excluded',
  );
  check(
    !matchesJourney(
      selected,
      Journey('Dhumbarahi', 'Sanepa', departure, 'Everyone'),
      now,
    ),
    'unrelated destination excluded',
  );
  check(
    !matchesJourney(
      selected,
      Journey(
        'Dhumbarahi',
        'PCPS College',
        departure.add(const Duration(days: 1)),
        'Everyone',
      ),
      now,
    ),
    'wrong date excluded',
  );
  check(
    !matchesJourney(
      selected,
      Journey('Dhumbarahi', 'PCPS College', now, 'Everyone'),
      now,
    ),
    'past departures excluded',
  );
  check(
    !matchesJourney(
      selected,
      Journey(
        'Dhumbarahi',
        'PCPS College',
        departure.add(const Duration(minutes: 61)),
        'Everyone',
      ),
      now,
    ),
    'departures outside the matching window excluded',
  );
  final gps = Journey(
    'Current location',
    'PCPS College',
    departure,
    'Everyone',
    latitude: 27.73,
    longitude: 85.35,
  );
  check(
    matchesJourney(
      gps,
      Journey(
        'Nearby',
        'PCPS College',
        departure,
        'Everyone',
        latitude: 27.735,
        longitude: 85.35,
      ),
      now,
    ),
    'nearby GPS pickup matches',
  );
  check(
    !matchesJourney(
      gps,
      Journey(
        'Far away',
        'PCPS College',
        departure,
        'Everyone',
        latitude: 27.68,
        longitude: 85.35,
      ),
      now,
    ),
    'distant GPS pickup excluded',
  );
  final trip = PreviewTrip(
    selected,
    host: 'Driver',
    capacity: 1,
    vehicle: 'Bike',
    freeRequest: false,
    mine: true,
  );
  trip.pendingMembers.add('Passenger');
  check(trip.acceptMember('Passenger'), 'pending passenger accepted');
  check(!trip.join('Passenger'), 'duplicate passenger excluded');
  trip.pendingMembers.add('Second passenger');
  check(
    !trip.acceptMember('Second passenger') && trip.seats == 0,
    'full vehicle rejects a second passenger',
  );
}
