import 'package:flutter/material.dart';

import 'package:routo/controllers/ride_matching_controller.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/journey.dart';
import 'package:routo/models/preview_trip.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/dashboard/fare_page.dart';
import 'package:routo/views/setup/journey_setup.dart';
import 'package:routo/views/setup/preview_setup.dart';
import 'package:routo/views/trips/chat_page.dart';
import 'package:routo/views/trips/trip_details.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/profile_avatar.dart';
import 'package:routo/views/widgets/screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.profile});
  final StudentProfile profile;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final trips = <PreviewTrip>[];
  final notifications = <String>[];
  final blocked = <String>{};
  int tab = 0;
  bool upcoming = false;
  bool closestFirst = true;
  String notificationFilter = 'All';
  String search = '';

  StudentProfile get profile => widget.profile;
  Journey get journey => profile.journey!;
  String get role => profile.driver ? 'Driver' : 'Passenger';

  @override
  void dispose() {
    ChatAlerts.stop();
    super.dispose();
  }

  List<PreviewTrip> get matches {
    final now = DateTime.now();
    final result = trips
        .where(
          (trip) =>
      !trip.mine &&
          !blocked.contains(trip.host) &&
          trip.status == TripStatus.available &&
          trip.seats > 0 &&
          (profile.driver == trip.freeRequest) &&
          matchesJourney(journey, trip.journey, now),
    )
        .toList();
    result.sort(
          (a, b) => closestFirst
          ? a.journey.departure
          .difference(journey.departure)
          .abs()
          .compareTo(
        b.journey.departure.difference(journey.departure).abs(),
      )
          : a.journey.departure.compareTo(b.journey.departure),
    );
    return result;
  }

  String when(Journey value) {
    final info = MaterialLocalizations.of(context);
    return '${info.formatMediumDate(value.departure)} · ${TimeOfDay.fromDateTime(value.departure).format(context)}';
  }

  Future<void> editJourney() async {
    await showPage(context, JourneySetup(profile: profile, edit: true));
    if (mounted) setState(() {});
  }

  void addExample() {
    final now = DateTime.now();

    if (!journey.departure.isAfter(now)) {
      notice(context, 'Set a future departure first.');
      return;
    }

    const exampleNames = ['Loren', 'Sunita', 'Erick'];

    final usedNames = trips
        .where(
          (trip) =>
      !trip.mine &&
          trip.freeRequest == profile.driver &&
          matchesJourney(journey, trip.journey, now),
    )
        .map((trip) => trip.host)
        .toSet();

    for (final name in exampleNames) {
      if (usedNames.contains(name) || blocked.contains(name)) continue;

      setState(() {
        trips.add(
          PreviewTrip(
            journey,
            host: name,
            capacity: 3,
            vehicle: 'Car',
            fare: profile.driver ? 0 : 50,
            freeRequest: profile.driver,
            mine: false,
          ),
        );
      });
      return;
    }

    notice(context, 'No more example matches for this journey.');
  }

  Future<double?> fareChoice({required bool offering, double suggested = 0}) =>
      showPage<double>(
        context,
        FarePage(offering: offering, suggested: suggested),
      );

  Future<void> createTrip() async {
    if (!journey.departure.isAfter(DateTime.now())) {
      notice(context, 'Set a future departure before posting.');
      return;
    }
    final fare = profile.driver ? await fareChoice(offering: true) : 0.0;
    if (!mounted || fare == null) return;
    if (trips.any(
          (trip) =>
      trip.mine &&
          identical(trip.journey, journey) &&
          trip.status != TripStatus.completed &&
          trip.status != TripStatus.declined,
    )) {
      notice(context, 'You already posted this journey.');
      return;
    }
    setState(
          () => trips.add(
        PreviewTrip(
          journey,
          host: profile.name,
          capacity: profile.driver ? profile.capacity : 3,
          vehicle: profile.vehicle,
          freeRequest: !profile.driver,
          mine: true,
          fare: fare,
        ),
      ),
    );
    notice(
      context,
      profile.driver
          ? 'Preview ride published.'
          : 'Preview free ride request created.',
    );
  }

  PreviewTrip? postedCarFor(PreviewTrip request) {
    for (final ride in trips) {
      if (ride.mine &&
          !ride.freeRequest &&
          ride.vehicle == 'Car' &&
          identical(ride.journey, request.journey) &&
          ride.status != TripStatus.completed &&
          ride.status != TripStatus.declined) {
        return ride;
      }
    }
    return null;
  }

  Future<void> openTrip(PreviewTrip trip) async {
    await showPage(
      context,
      TripDetails(
        trip: trip,
        postedCar: postedCarFor(trip),
        profile: profile,
        when: when(trip.journey),
        fareChoice: fareChoice,
        onUpdate: (message) {
          if (mounted) setState(() => notifications.insert(0, message));
        },
        onBlock: (name) {
          if (mounted) setState(() => blocked.add(name));
        },
      ),
    );
    if (mounted) setState(() {});
  }

  Widget tripCard(PreviewTrip trip) => Panel(
    color: const Color(0xffeeeeee),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const ProfileAvatar(),
      title: Text(
        trip.host,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${trip.journey.pickup} → ${trip.journey.destination}\n'
            '${when(trip.journey)}\n'
            '${trip.freeRequest ? 'Free ride request' : '${trip.vehicle} · ${trip.seats} seats'}'
            ' · ${trip.status.name}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => openTrip(trip),
    ),
  );

  List<Widget> home() => [
    Panel(
      color: teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Good morning, ${profile.name}!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 23,
                    color: Colors.white,
                  ),
                ),
              ),
              ProfileAvatar(photo: profile.photo),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$role',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    Panel(
      border: sand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Journey',
            style: TextStyle(
              fontSize: 19,
              color: teal,
              fontWeight: FontWeight.w800,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: Text(journey.pickup),
            subtitle: const Text('Starting point'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.school_outlined),
            title: Text(journey.destination),
            subtitle: Text(when(journey)),
          ),
        ],
      ),
    ),
    Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 8,
      runSpacing: 12,
      children: [
        shortcut(
          Icons.group_outlined,
          'Matches',
              () => setState(() => tab = 1),
        ),
        shortcut(Icons.history, 'History', showHistory),
        shortcut(
          Icons.chat_bubble_outline,
          'Messages',
              () => setState(() => tab = 2),
        ),
        shortcut(Icons.edit_outlined, 'Edit', editJourney),
      ],
    ),
    const SizedBox(height: 20),
    const Heading('Suggested Matches'),
    if (matches.isEmpty)
      const Text(
        'No matching journeys for this pickup, destination and departure.',
      ),
    ...matches.take(2).map(tripCard),
    if (trips.any((trip) => trip.mine)) ...[
      const SizedBox(height: 18),
      const Heading('Your Posts'),
      ...trips.where((trip) => trip.mine).map(tripCard),
    ],
    PrimaryAction(
      profile.driver ? 'Offer a Ride' : 'Create Free Ride Request',
      createTrip,
    ),
  ];

  Widget shortcut(IconData icon, String label, VoidCallback action) => Column(
    children: [
      IconButton.filledTonal(
        onPressed: action,
        tooltip: label,
        icon: Icon(icon, color: teal),
      ),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center),
    ],
  );

  List<Widget> results() => [
    Panel(
      border: sand,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(when(journey)),
        subtitle: Text('${journey.pickup} → ${journey.destination}'),
        trailing: const Icon(Icons.edit_outlined),
        onTap: editJourney,
      ),
    ),
    DropdownButtonFormField<bool>(
      isExpanded: true,
      initialValue: closestFirst,
      decoration: const InputDecoration(labelText: 'Sort'),
      items: const [
        DropdownMenuItem(value: true, child: Text('Closest departure match')),
        DropdownMenuItem(value: false, child: Text('Earliest departure')),
      ],
      onChanged: (value) => setState(() => closestFirst = value!),
    ),
    const SizedBox(height: 18),
    if (matches.isEmpty)
      const Heading(
        'No matching rides',
        'Try changing your journey or add a preview example.',
      ),
    ...matches.map(tripCard),
    PrimaryAction('Add Example Match', addExample, secondary: true),
    if (!profile.driver && matches.isEmpty)
      PrimaryAction('Create Free Ride Request', createTrip),
  ];

  List<Widget> messages() => [
    TextField(
      decoration: const InputDecoration(
        labelText: 'Search conversations',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) => setState(() => search = value.trim().toLowerCase()),
    ),
    const SizedBox(height: 18),
    if (!trips.any(canShowChat)) const Text('No conversations found.'),
    ...trips
        .where(canShowChat)
        .map(
          (trip) => ListTile(
        leading: trip.vehicle == 'Car'
            ? const CircleAvatar(
          backgroundColor: mint,
          child: Icon(Icons.groups_outlined, color: forest),
        )
            : const ProfileAvatar(),
        title: Text(
          trip.vehicle == 'Car'
              ? 'Journey Chat · ${trip.journey.destination}'
              : trip.host,
        ),
        subtitle: Text(
          trip.messages.isEmpty
              ? 'Start a conversation'
              : trip.messages.last,
        ),
        onTap: () async {
          await showPage(context, ChatPage(trip: trip));
          if (mounted) setState(() {});
        },
      ),
    ),
  ];

  bool canShowChat(PreviewTrip trip) {
    if (trip.acceptedCarRide != null) return false;
    if (blocked.contains(trip.host)) return false;

    if (trip.status != TripStatus.accepted &&
        trip.status != TripStatus.completed) {
      return false;
    }

    final names = <String>[trip.host];
    if (trip.vehicle == 'Car') {
      names.addAll(['Journey Chat', trip.journey.destination, ...trip.members]);
    }

    return names.any((name) => name.toLowerCase().contains(search));
  }

  List<Widget> me() => [
    Center(child: ProfileAvatar(photo: profile.photo, radius: 45)),
    const SizedBox(height: 12),
    Heading(profile.name, '$role · ${profile.section}', forest, true),
    PrimaryAction('Edit Profile', () async {
      await showPage(context, PreviewSetup(profile: profile));
      if (mounted) setState(() {});
    }),
    ListTile(
      leading: const Icon(Icons.place_outlined),
      title: const Text('Address'),
      onTap: editJourney,
    ),
    ListTile(
      leading: const Icon(Icons.route_outlined),
      title: const Text('My Journeys'),
      onTap: showHistory,
    ),
    ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: const Text('Notifications'),
      onTap: showNotifications,
    ),
    ListTile(
      leading: const Icon(Icons.block),
      title: const Text('Blocked Accounts'),
      onTap: showBlocked,
    ),
    ListTile(
      leading: const Icon(Icons.settings_outlined),
      title: const Text('Settings'),
      onTap: () => showPage(
        context,
        Screen(
          title: 'Settings',
          children: [
            const Text('Frontend preview'),
            PrimaryAction('Edit Journey', editJourney),
            PrimaryAction('Logout', logout, secondary: true),
          ],
        ),
      ),
    ),
    ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: logout,
    ),
  ];

  void logout() => Navigator.of(context).popUntil((route) => route.isFirst);

  void showHistory() => showPage(
    context,
    StatefulBuilder(
      builder: (context, refresh) => Screen(
        title: 'Ride History',
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Past')),
              ButtonSegment(value: true, label: Text('Upcoming')),
            ],
            selected: {upcoming},
            onSelectionChanged: (value) =>
                refresh(() => upcoming = value.first),
          ),
          const SizedBox(height: 16),
          if (!trips.any(historyFilter)) const Text('No journeys to show.'),
          ...trips
              .where(historyFilter)
              .map(
                (trip) => Panel(
              color: const Color(0xffeeeeee),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${trip.journey.pickup} → ${trip.journey.destination}',
                ),
                subtitle: Text(
                  '${when(trip.journey)} · ${trip.status.name}',
                ),
                onTap: () async {
                  await openTrip(trip);
                  if (context.mounted) refresh(() {});
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );

  bool historyFilter(PreviewTrip trip) {
    if (blocked.contains(trip.host) ||
        (!trip.mine && trip.status == TripStatus.available))
      return false;
    final isPast =
        trip.status == TripStatus.completed ||
            trip.status == TripStatus.declined ||
            !trip.journey.departure.isAfter(DateTime.now());
    return upcoming != isPast;
  }

  void showNotifications() => showPage(
    context,
    StatefulBuilder(
      builder: (context, refresh) {
        final visible = notifications.where(
              (message) =>
          notificationFilter == 'All' ||
              (notificationFilter == 'Matches' &&
                  !message.startsWith('Message')) ||
              (notificationFilter == 'Messages' &&
                  message.startsWith('Message')),
        );
        return Screen(
          title: 'Notifications',
          background: cream,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', 'Matches', 'Messages']
                  .map(
                    (value) => ChoiceChip(
                  label: Text(value),
                  selected: notificationFilter == value,
                  onSelected: (_) =>
                      refresh(() => notificationFilter = value),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 16),
            if (visible.isEmpty) const Text('You’re all caught up.'),
            ...visible.map(
                  (message) => ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(message),
              ),
            ),
          ],
        );
      },
    ),
  );

  void showBlocked() => showPage(
    context,
    StatefulBuilder(
      builder: (context, refresh) => Screen(
        title: 'Blocked Accounts',
        background: lilac,
        children: [
          if (blocked.isEmpty) const Text('No blocked accounts.'),
          for (final name in blocked)
            ListTile(
              leading: const ProfileAvatar(),
              title: Text(name),
              trailing: OutlinedButton(
                onPressed: () {
                  setState(() => blocked.remove(name));
                  refresh(() {});
                },
                child: const Text('Unblock'),
              ),
            ),
          const SizedBox(height: 24),
          const Panel(
            color: Color(0xffeeeeee),
            child: Text(
              'Blocked accounts are hidden from matches, messages and ride history in this preview.',
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Real-time chat popups: safe to call on every rebuild.
    ChatAlerts.watch(
      trips,
      blocked: blocked,
      onChange: (note) {
        if (!mounted) return;
        setState(() {
          if (note != null) notifications.insert(0, note);
        });
      },
    );
    return PopScope(
      canPop: tab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && tab != 0) {
          _goHome();
        }
      },
      child: _buildDashboard(context),
    );
  }

  void _goHome() {
    setState(() => tab = 0);
  }

  Widget _buildDashboard(BuildContext context) => Screen(
    leading: tab == 0 ? null : BackButton(onPressed: _goHome),
    title: ['яouto', 'Matches', 'Messages', 'Me'][tab],
    background: [mint, Colors.white, cream, lilac][tab],
    headerColor: tab == 0 ? teal : null,
    drawer: tab == 0 ? Drawer(
      backgroundColor: mint,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: me(),
        ),
      ),
    ) : null,
    actions: tab == 0 ? [
      IconButton(
        tooltip: 'Notifications',
        onPressed: showNotifications,
        icon: const Icon(Icons.notifications_outlined),
      ),
    ] : null,
    footer: NavigationBar(
      backgroundColor: tab == 0 ? const Color(0xffe2e5dc) : Colors.white,
      indicatorColor: mint,
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          label: 'Matches',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
      ],
    ),
    children: switch (tab) {
      0 => home(),
      1 => results(),
      2 => messages(),
      _ => me(),
    },
  );
}