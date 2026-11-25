import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/preview_trip.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/trips/chat_page.dart';
import 'package:routo/views/trips/report_page.dart';
import 'package:routo/views/trips/review_page.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/profile_avatar.dart';
import 'package:routo/views/widgets/screen.dart';
import 'package:routo/core/ride_notifications.dart';

class TripDetails extends StatefulWidget {
  const TripDetails({
    super.key,
    required this.trip,
    this.postedCar,
    required this.profile,
    required this.when,
    required this.fareChoice,
    required this.onUpdate,
    required this.onBlock,
  });
  final PreviewTrip trip;
  final PreviewTrip? postedCar;
  final StudentProfile profile;
  final String when;
  final Future<double?> Function({required bool offering, double suggested})
  fareChoice;
  final ValueChanged<String> onUpdate;
  final ValueChanged<String> onBlock;

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  PreviewTrip get trip => widget.trip.acceptedCarRide ?? widget.trip;
  bool get isOpen => trip.journey.departure.isAfter(DateTime.now());
  bool get canAct =>
      isOpen &&
          !trip.mine &&
          trip.status == TripStatus.available &&
          trip.seats > 0;
  final comment = TextEditingController();

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  void changeStatus(TripStatus status, String message) {
    setState(() => trip.status = status);
    widget.onUpdate(message);
  }

  Future<void> request() async {
    if (!canAct || widget.profile.driver || trip.freeRequest) return;
    final amount = await widget.fareChoice(
      offering: false,
      suggested: trip.fare,
    );
    if (!mounted || amount == null || !canAct) return;
    trip.contribution = amount;
    changeStatus(
      TripStatus.pending,
      'Preview request to join ${trip.host} sent.',
    );
    await RideNotifications.showRequestSent();
  }
  Future<void> previewDriverDecision() async {
    if (trip.status != TripStatus.pending || !isOpen) return;

    final passenger = widget.profile.name.trim();
    if (passenger.isEmpty) {
      notice(context, 'Add your name to your profile first.');
      return;
    }

    final accepted = await showPage<bool>(
      context,
      Builder(
        builder: (pageContext) => Screen(
          title: 'Driver preview',
          background: cream,
          children: [
            const Heading(
              'Incoming ride request',
              'Preview what the driver sees for this request.',
            ),
            Panel(
              border: sand,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: mint,
                      child: Icon(Icons.person_outline, color: forest),
                    ),
                    title: Text(
                      passenger,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('Wants to join ${trip.host}’s ride'),
                  ),
                  const Divider(),
                  Text('${trip.journey.pickup} → ${trip.journey.destination}'),
                  const SizedBox(height: 8),
                  Text(widget.when),
                  const SizedBox(height: 8),
                  Text(
                    'Offered contribution · Rs. '
                        '${trip.contribution.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
            PrimaryAction(
              'Accept request',
              trip.seats > 0
                  ? () => Navigator.of(pageContext).pop(true)
                  : null,
            ),
            PrimaryAction(
              'Reject request',
                  () => Navigator.of(pageContext).pop(false),
              secondary: true,
            ),
          ],
        ),
      ),
    );

    // Going back without choosing keeps the request pending.
    if (!mounted || accepted == null || trip.status != TripStatus.pending) {
      return;
    }

    if (!isOpen) {
      notice(context, 'This ride has already departed.');
      return;
    }

    if (!accepted) {
      changeStatus(
        TripStatus.declined,
        '${trip.host} declined your ride request.',
      );
      return;
    }

    // The existing model adds the passenger and counts the occupied seat.
    if (!trip.join(passenger)) {
      notice(context, 'This passenger could not be added to the ride.');
      return;
    }

    changeStatus(
      TripStatus.accepted,
      '${trip.host} accepted your request. Your journey chat is ready.',
    );
  }

  Future<void> acceptPassenger() async {
    if (!canAct || !widget.profile.driver || !trip.freeRequest) return;

    final request = widget.trip;

    if (widget.profile.vehicle == 'Car') {
      final car = widget.postedCar;

      if (car == null) {
        notice(context, 'Post your car ride for this journey first.');
        return;
      }

      if (!car.journey.departure.isAfter(DateTime.now()) ||
          car.status == TripStatus.completed ||
          car.status == TripStatus.declined) {
        notice(context, 'This car ride is no longer open.');
        return;
      }

      if (car.members.contains(request.host)) {
        notice(context, '${request.host} is already in this car.');
        return;
      }

      if (!car.join(request.host)) {
        notice(context, 'No passenger seats left in this car.');
        return;
      }

      setState(() {
        car.pendingMembers.remove(request.host);
        car.status = TripStatus.accepted;
        request.status = TripStatus.accepted;
        request.acceptedCarRide = car;
      });

      widget.onUpdate('${request.host} joined your car ride.');
      await RideNotifications.showUpdate('Request accepted', '${request.host} joined your car ride.');
      return;
    }

    // Existing bike and scooter flow.
    if (!request.join(request.host)) return;
    changeStatus(
      TripStatus.accepted,
      'You accepted ${request.host}’s preview ride request.',
    );
    await RideNotifications.showUpdate('Request accepted', 'You accepted ${request.host}’s ride request.');
  }

  Future<void> report() async {
    final result = await showPage<String>(context, ReportPage(name: trip.host));
    if (!mounted || result == null) return;
    if (result == 'block') {
      widget.onBlock(trip.host);
      Navigator.of(context).pop();
    } else {
      notice(context, 'Report recorded for this preview session.');
    }
  }

  @override
  Widget build(BuildContext context) => Screen(
    title: 'Trip Details',
    background: cream,
    children: [
      Panel(
        color: const Color(0xffe4e8e2),
        child: Row(
          children: [
            const ProfileAvatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Heading(
                trip.host,
                trip.freeRequest
                    ? 'Passenger · Free request'
                    : 'Driver · ${trip.vehicle}',
                teal,
              ),
            ),
          ],
        ),
      ),
      Panel(
        border: sand,
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(trip.journey.pickup),
              subtitle: const Text('Starting point'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school_outlined),
              title: Text(trip.journey.destination),
              subtitle: const Text('Destination'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(widget.when),
              subtitle: Text(trip.status.name.toUpperCase()),
            ),
          ],
        ),
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journey Group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (!widget.profile.driver &&
                (!trip.freeRequest ||
                    trip.status == TripStatus.accepted ||
                    trip.status == TripStatus.completed))
              Text('${trip.seats} passenger seats available'),
            Text(
              trip.members.isEmpty
                  ? 'No joined passengers'
                  : trip.members.join(', '),
            ),
            if (trip.fare > 0)
              Text('Suggested fare · Rs. ${trip.fare.toStringAsFixed(2)}'),
            if (!trip.mine &&
                !trip.freeRequest &&
                trip.status != TripStatus.available)
              Text(
                'Your contribution · Rs. ${trip.contribution.toStringAsFixed(2)}',
              ),
          ],
        ),
      ),
      if (canAct && !widget.profile.driver && !trip.freeRequest)
        PrimaryAction('Join Match', request),
      if (canAct && widget.profile.driver && trip.freeRequest) ...[
        PrimaryAction('Accept', acceptPassenger),
        PrimaryAction(
          'Reject',
              () async {
            final host = trip.host;
            changeStatus(TripStatus.declined, 'You declined $host’s preview request.');
            await RideNotifications.showUpdate('Request declined', 'You declined $host’s ride request.');
          },
          secondary: true,
        ),
      ],
      if (widget.profile.driver && trip.mine && isOpen) ...[
        const Heading('Incoming Requests'),
        if (trip.pendingMembers.isEmpty) const Text('No pending requests.'),
        for (final name in trip.pendingMembers)
          Panel(
            border: sand,
            child: Column(
              children: [
                Text(name),
                PrimaryAction(
                  'Accept',
                  trip.seats == 0
                      ? null
                      : () async {
                    if (!trip.acceptMember(name)) return;
                    changeStatus(
                      TripStatus.accepted,
                      'You accepted $name.',
                    );
                    await RideNotifications.showUpdate('Request accepted', 'You accepted $name.');
                  },
                ),
                PrimaryAction('Reject', () async {
                  setState(() => trip.pendingMembers.remove(name));
                  widget.onUpdate('You declined $name.');
                  await RideNotifications.showUpdate('Request declined', 'You declined $name.');
                }, secondary: true),
              ],
            ),
          ),
        PrimaryAction(
          'Add Example Request',
          trip.seats == 0
              ? null
              : () {
            final name = ['Erick', 'Evaa', 'Sunita', 'Alex'].firstWhere(
                  (name) =>
              !trip.members.contains(name) &&
                  !trip.pendingMembers.contains(name) &&
                  name != trip.host,
              orElse: () => '',
            );
            if (name.isNotEmpty) {
              setState(() => trip.pendingMembers.add(name));
              widget.onUpdate(
                '$name requested to join your ride from '
                    '${trip.journey.pickup} to ${trip.journey.destination}.',
              );
            }
          },
          secondary: true,
        ),
      ],
      if (trip.status == TripStatus.pending) ...[
        const Panel(
          child: Text('Your request is pending driver approval.'),
        ),
      ],

      if (trip.status == TripStatus.declined)
        Panel(
          border: sand,
          child: Text('${trip.host} declined this ride request.'),
        ),
      if (trip.status == TripStatus.accepted) ...[
        const Heading(
          'You’re Connected!',
          'Your preview ride was accepted.',
          forest,
          true,
        ),
        PrimaryAction(
          'Open Chat',
              () => showPage(
            context,
            ChatPage(trip: trip, onUpdate: widget.onUpdate),
          ),
        ),
        if (widget.profile.driver)
          PrimaryAction(
            'Mark Ride Completed',
                () => changeStatus(
              TripStatus.completed,
              'Your preview ride was completed.',
            ),
            secondary: true,
          ),
      ],
      if (trip.status == TripStatus.completed && !trip.mine) ...[
        PrimaryAction(
          trip.stars == null ? 'Rate Your Ride' : 'Edit Review',
              () async {
            await showPage(context, ReviewPage(trip: trip));
            if (mounted) setState(() {});
          },
        ),
        const SizedBox(height: 20),
        const Heading('Comments'),
        for (final text in trip.comments) ListTile(title: Text(text)),
        Field('Write a comment', comment, lines: 2),
        PrimaryAction('Post Comment', () {
          final text = comment.text.trim();
          if (text.isEmpty) return;
          setState(() {
            trip.comments.add(text);
            comment.clear();
          });
        }, secondary: true),
      ],
      if (!trip.mine)
        TextButton(
          onPressed: report,
          child: const Text(
            'Report or Block',
            style: TextStyle(color: Colors.red),
          ),
        ),
    ],
  );
}
