class Journey {
  const Journey(
      this.pickup,
      this.destination,
      this.departure,
      this.preference, {
        this.latitude,
        this.longitude,
      });
  final String pickup;
  final String destination;
  final DateTime departure;
  final String preference;
  final double? latitude;
  final double? longitude;
}