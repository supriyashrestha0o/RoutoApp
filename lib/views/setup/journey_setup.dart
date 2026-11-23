import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

import 'package:routo/controllers/validators.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/journey.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/setup/role_page.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

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