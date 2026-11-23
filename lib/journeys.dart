import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

import 'account.dart';
import 'dashboard.dart';
import 'design.dart';
import 'ride_model.dart';

class JourneySetup extends StatefulWidget {
  const JourneySetup({super.key, required this.profile, this.edit = false});
  final StudentProfile profile;
  final bool edit;

  @override
  State<JourneySetup> createState() => _JourneySetupState();
}

class _JourneySetupState extends State<JourneySetup> {
  final form = GlobalKey<FormState>();
  late final pickup = TextEditingController(
    text: widget.profile.journey?.pickup,
  );
  late final destination = TextEditingController(
    text: widget.profile.journey?.destination,
  );
  late DateTime date =
      widget.profile.journey?.departure ??
      DateTime.now().add(const Duration(minutes: 30));
  late TimeOfDay time = TimeOfDay.fromDateTime(
    widget.profile.journey?.departure ??
        DateTime.now().add(const Duration(minutes: 30)),
  );
  late String preference = widget.profile.journey?.preference ?? 'Everyone';
  late double? latitude = widget.profile.journey?.latitude;
  late double? longitude = widget.profile.journey?.longitude;
  bool locating = false;
  int pickupRevision = 0;

  @override
  void initState() {
    super.initState();
    if (widget.profile.journey == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) locate();
      });
    }
  }

  @override
  void dispose() {
    pickup.dispose();
    destination.dispose();
    super.dispose();
  }

  Future<void> locate() async {
    setState(() => locating = true);
    final revision = pickupRevision;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Location services are off.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw StateError('Location access is unavailable.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (!mounted || revision != pickupRevision) return;

      final lat = position.latitude;
      final lng = position.longitude;
      String placeName = '';

      try {
        final places = await geo
            .placemarkFromCoordinates(lat, lng)
            .timeout(const Duration(seconds: 5));

        if (places.isNotEmpty) {
          final place = places.first;
          final parts = <String>{};

          for (final value in [place.street, place.subLocality, place.locality]) {
            final part = value?.trim() ?? '';
            if (part.isNotEmpty) parts.add(part);
          }

          placeName = parts.join(', ');
        }
      } catch (_) {
        // GPS can succeed even when the address service is unavailable.
      }

// Keep a pickup that the user typed while the address was loading.
      if (!mounted || revision != pickupRevision) return;

      latitude = lat;
      longitude = lng;
      pickup.text = placeName.isNotEmpty
          ? placeName
          : 'Current location (${lat.toStringAsFixed(4)}, '
          '${lng.toStringAsFixed(4)})';
    } catch (_) {
      if (mounted)
        notice(
          context,
          'Could not get your location. Enter a pickup manually.',
        );
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  void save() {
    if (!form.currentState!.validate()) return;
    final departure = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!departure.isAfter(DateTime.now())) {
      notice(context, 'Choose a departure in the future.');
      return;
    }
    if (pickup.text.trim().toLowerCase() ==
        destination.text.trim().toLowerCase()) {
      notice(context, 'Pickup and destination must be different.');
      return;
    }
    widget.profile.journey = Journey(
      pickup.text.trim(),
      destination.text.trim(),
      departure,
      preference,
      latitude: latitude,
      longitude: longitude,
    );
    if (widget.edit) {
      Navigator.of(context).pop(true);
    } else {
      showPage(context, RolePage(profile: widget.profile));
    }
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: widget.edit ? null : 2,
    children: [
      const Heading(
        'Set Your Journey',
        'Where do you usually start your journey?',
      ),
      Form(
        key: form,
        child: Column(
          children: [
            Field(
              'Starting Location',
              pickup,
              icon: Icons.location_on_outlined,
              validator: requiredField,
              onChanged: (_) {
                pickupRevision++;
                latitude = longitude = null;
              },
              suffix: IconButton(
                tooltip: 'Use GPS',
                onPressed: locating ? null : locate,
                icon: locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
              ),
            ),
            Field(
              'Destination',
              destination,
              icon: Icons.flag_outlined,
              validator: requiredField,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Travel Date'),
              subtitle: Text(
                MaterialLocalizations.of(context).formatMediumDate(date),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final today = DateUtils.dateOnly(DateTime.now());
                final result = await showDatePicker(
                  context: context,
                  firstDate: today,
                  lastDate: today.add(const Duration(days: 365)),
                  initialDate: date.isBefore(today) ? today : date,
                );
                if (mounted && result != null) setState(() => date = result);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Departure Time'),
              subtitle: Text(time.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (mounted && result != null) setState(() => time = result);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: preference,
              decoration: const InputDecoration(
                labelText: 'Show Matches Who Are',
              ),
              items: [
                'Everyone',
                'Male',
                'Female',
                'Other',
              ].map(option).toList(),
              onChanged: (value) => setState(() => preference = value!),
            ),
          ],
        ),
      ),
      PrimaryAction(widget.edit ? 'Save Journey' : 'Continue', save),
    ],
  );
}

class RolePage extends StatefulWidget {
  const RolePage({super.key, required this.profile});
  final StudentProfile profile;

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  bool driver = false;

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: 3,
    children: [
      const Heading('How do you Travel?', 'How would you like to use Routo?'),
      for (final offer in [false, true])
        Panel(
          color: mint,
          border: driver == offer ? sand : Colors.black26,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: sand,
              child: Icon(
                offer ? Icons.directions_car_outlined : Icons.person_outline,
                color: Colors.black,
              ),
            ),
            title: Text(
              offer ? 'Offer a Ride' : 'Find a Ride',
              style: const TextStyle(
                color: forest,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              offer
                  ? 'Share your ride with other students'
                  : 'Find students traveling along your route',
            ),
            trailing: Icon(
              driver == offer
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: driver == offer ? sand : teal,
            ),
            onTap: () => setState(() => driver = offer),
          ),
        ),
      const SizedBox(height: 16),
      PrimaryAction('Continue', () {
        widget.profile.driver = driver;
        showPage(
          context,
          driver
              ? VehiclePage(profile: widget.profile)
              : SetupComplete(profile: widget.profile),
        );
      }),
    ],
  );
}

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key, required this.profile});
  final StudentProfile profile;

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final form = GlobalKey<FormState>();
  final model = TextEditingController();
  final number = TextEditingController();
  String type = 'Bike';
  int seats = 1;

  @override
  void dispose() {
    model.dispose();
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: 3,
    children: [
      const Heading('Vehicle Information', 'Tell us about your vehicle'),
      Row(
        spacing: 10,
        children: [
          for (final entry in const {
            'Bike': Icons.two_wheeler,
            'Scooter': Icons.moped,
            'Car': Icons.directions_car_outlined,
          }.entries)
            Expanded(
              child: ChoiceChip(
                selected: type == entry.key,
                showCheckmark: false,
                selectedColor: cream,
                backgroundColor: mint,
                side: BorderSide(
                  color: type == entry.key ? sand : Colors.black26,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                label: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entry.value, size: 34, color: Colors.black),
                      const SizedBox(height: 12),
                      Text(
                        entry.key,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: forest,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                onSelected: (_) => setState(() {
                  type = entry.key;
                  if (type != 'Car') seats = 1;
                }),
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Form(
        key: form,
        child: Column(
          children: [
            Field('Vehicle Model', model, validator: requiredField),
            Field('Vehicle Number', number, validator: requiredField),
            if (type == 'Car')
              DropdownButtonFormField<int>(
                initialValue: seats,
                decoration: const InputDecoration(labelText: 'Passenger seats'),
                items: [1, 2, 3]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text('$value')),
                    )
                    .toList(),
                onChanged: (value) => setState(() => seats = value!),
              ),
          ],
        ),
      ),
      PrimaryAction('Continue', () {
        if (!form.currentState!.validate()) return;
        widget.profile
          ..vehicle = type
          ..model = model.text.trim()
          ..capacity = seats;
        showPage(context, VerificationPage(profile: widget.profile));
      }),
    ],
  );
}

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, required this.profile});
  final StudentProfile profile;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final selected = <String>{};

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: 4,
    children: [
      const Heading(
        'Verification Documents',
        'Try the verification screen with sample documents.',
      ),
      for (final title in ['Driving License', 'Citizenship'])
        Panel(
          border: sand,
          color: mint,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: Text(title),
            subtitle: Text(selected.contains(title) ? 'Sample selected' : 'Front & back'),
            trailing: TextButton(
              onPressed: () => setState(() {
                if (!selected.add(title)) selected.remove(title);
              }),
              child: Text(selected.contains(title) ? 'Remove' : 'Choose sample'),
            ),
          ),
        ),
      PrimaryAction(
        'Submit for Verification',
        selected.length == 2 ? () => showPage(context, SetupComplete(profile: widget.profile)) : null,
      ),
      PrimaryAction(
        'Maybe Later',
        () => showPage(context, SetupComplete(profile: widget.profile)),
        secondary: true,
      ),
    ],
  );
}

class SetupComplete extends StatelessWidget {
  const SetupComplete({super.key, required this.profile});
  final StudentProfile profile;

  @override
  Widget build(BuildContext context) => Screen(
    children: [
      const SizedBox(height: 30),
      const Icon(Icons.check_circle, color: forest, size: 104),
      const SizedBox(height: 24),
      const Heading(
        'You’re all set!',
        'Your preview profile and journey are ready.',
        forest,
        true,
      ),
      Image.asset(
        'assets/setup-campus.webp',
        height: 220,
        excludeFromSemantics: true,
      ),
      PrimaryAction(
        'Continue',
        () => showPage(context, Dashboard(profile: profile)),
      ),
    ],
  );
}
