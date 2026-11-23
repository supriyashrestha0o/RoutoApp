import 'package:flutter/material.dart';

import 'account.dart';
import 'design.dart';
import 'journeys.dart';
import 'ride_model.dart';

// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key, required this.profile});
//   final StudentProfile profile;
//
//   @override
//   State<Dashboard> createState() => _DashboardState();
// }
//
// class _DashboardState extends State<Dashboard> {
//   final trips = <PreviewTrip>[];
//   final notifications = <String>[];
//   final blocked = <String>{};
//   int tab = 0;
//   bool upcoming = false;
//   bool closestFirst = true;
//   String notificationFilter = 'All';
//   String search = '';
//
//   StudentProfile get profile => widget.profile;
//   Journey get journey => profile.journey!;
//   String get role => profile.driver ? 'Driver' : 'Passenger';
//
//   List<PreviewTrip> get matches {
//     final now = DateTime.now();
//     final result = trips
//         .where(
//           (trip) =>
//               !trip.mine &&
//               !blocked.contains(trip.host) &&
//               trip.status == TripStatus.available &&
//               trip.seats > 0 &&
//               (profile.driver == trip.freeRequest) &&
//               matchesJourney(journey, trip.journey, now),
//         )
//         .toList();
//     result.sort(
//       (a, b) => closestFirst
//           ? a.journey.departure
//                 .difference(journey.departure)
//                 .abs()
//                 .compareTo(
//                   b.journey.departure.difference(journey.departure).abs(),
//                 )
//           : a.journey.departure.compareTo(b.journey.departure),
//     );
//     return result;
//   }
//
//   String when(Journey value) {
//     final info = MaterialLocalizations.of(context);
//     return '${info.formatMediumDate(value.departure)} · ${TimeOfDay.fromDateTime(value.departure).format(context)}';
//   }
//
//   Future<void> editJourney() async {
//     await showPage(context, JourneySetup(profile: profile, edit: true));
//     if (mounted) setState(() {});
//   }
//
//   void addExample() {
//     final now = DateTime.now();
//
//     if (!journey.departure.isAfter(now)) {
//       notice(context, 'Set a future departure first.');
//       return;
//     }
//
//     const exampleNames = ['Loren', 'Sunita', 'Erick'];
//
//     final usedNames = trips
//         .where(
//           (trip) =>
//       !trip.mine &&
//           trip.freeRequest == profile.driver &&
//           matchesJourney(journey, trip.journey, now),
//     )
//         .map((trip) => trip.host)
//         .toSet();
//
//     for (final name in exampleNames) {
//       if (usedNames.contains(name) || blocked.contains(name)) continue;
//
//       setState(() {
//         trips.add(
//           PreviewTrip(
//             journey,
//             host: name,
//             capacity: 3,
//             vehicle: 'Car',
//             fare: profile.driver ? 0 : 50,
//             freeRequest: profile.driver,
//             mine: false,
//           ),
//         );
//       });
//       return;
//     }
//
//     notice(context, 'No more example matches for this journey.');
//   }
//
//   Future<double?> fareChoice({required bool offering, double suggested = 0}) =>
//       showPage<double>(
//         context,
//         FarePage(offering: offering, suggested: suggested),
//       );
//
//   Future<void> createTrip() async {
//     if (!journey.departure.isAfter(DateTime.now())) {
//       notice(context, 'Set a future departure before posting.');
//       return;
//     }
//     final fare = profile.driver ? await fareChoice(offering: true) : 0.0;
//     if (!mounted || fare == null) return;
//     if (trips.any(
//       (trip) =>
//           trip.mine &&
//           identical(trip.journey, journey) &&
//           trip.status != TripStatus.completed &&
//           trip.status != TripStatus.declined,
//     )) {
//       notice(context, 'You already posted this journey.');
//       return;
//     }
//     setState(
//       () => trips.add(
//         PreviewTrip(
//           journey,
//           host: profile.name,
//           capacity: profile.driver ? profile.capacity : 3,
//           vehicle: profile.vehicle,
//           freeRequest: !profile.driver,
//           mine: true,
//           fare: fare,
//         ),
//       ),
//     );
//     notice(
//       context,
//       profile.driver
//           ? 'Preview ride published.'
//           : 'Preview free ride request created.',
//     );
//   }
//
//   PreviewTrip? postedCarFor(PreviewTrip request) {
//     for (final ride in trips) {
//       if (ride.mine &&
//           !ride.freeRequest &&
//           ride.vehicle == 'Car' &&
//           identical(ride.journey, request.journey) &&
//           ride.status != TripStatus.completed &&
//           ride.status != TripStatus.declined) {
//         return ride;
//       }
//     }
//     return null;
//   }
//
//   Future<void> openTrip(PreviewTrip trip) async {
//     await showPage(
//       context,
//       TripDetails(
//         trip: trip,
//         postedCar: postedCarFor(trip),
//         profile: profile,
//         when: when(trip.journey),
//         fareChoice: fareChoice,
//         onUpdate: (message) {
//           if (mounted) setState(() => notifications.insert(0, message));
//         },
//         onBlock: (name) {
//           if (mounted) setState(() => blocked.add(name));
//         },
//       ),
//     );
//     if (mounted) setState(() {});
//   }
//
//   Widget tripCard(PreviewTrip trip) => Panel(
//     color: const Color(0xffeeeeee),
//     child: ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: const ProfileAvatar(),
//       title: Text(
//         trip.host,
//         style: const TextStyle(fontWeight: FontWeight.w800),
//       ),
//       subtitle: Text(
//         '${trip.journey.pickup} → ${trip.journey.destination}\n'
//         '${when(trip.journey)}\n'
//         '${trip.freeRequest ? 'Free ride request' : '${trip.vehicle} · ${trip.seats} seats'}'
//         ' · ${trip.status.name}',
//       ),
//       trailing: const Icon(Icons.chevron_right),
//       onTap: () => openTrip(trip),
//     ),
//   );
//
//   List<Widget> home() => [
//     Panel(
//       color: teal,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Good morning, ${profile.name}!',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w900,
//                     fontSize: 23,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               ProfileAvatar(photo: profile.photo),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '$role · Frontend preview',
//             style: const TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     ),
//     Panel(
//       border: sand,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Your Journey',
//             style: TextStyle(
//               fontSize: 19,
//               color: teal,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             leading: const Icon(Icons.location_on_outlined),
//             title: Text(journey.pickup),
//             subtitle: const Text('Starting point'),
//           ),
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             leading: const Icon(Icons.school_outlined),
//             title: Text(journey.destination),
//             subtitle: Text(when(journey)),
//           ),
//         ],
//       ),
//     ),
//     Wrap(
//       alignment: WrapAlignment.spaceBetween,
//       spacing: 8,
//       runSpacing: 12,
//       children: [
//         shortcut(
//           Icons.group_outlined,
//           'Matches',
//           () => setState(() => tab = 1),
//         ),
//         shortcut(Icons.history, 'History', showHistory),
//         shortcut(
//           Icons.chat_bubble_outline,
//           'Messages',
//           () => setState(() => tab = 2),
//         ),
//         shortcut(Icons.edit_outlined, 'Edit', editJourney),
//       ],
//     ),
//     const SizedBox(height: 20),
//     const Heading('Suggested Matches'),
//     if (matches.isEmpty)
//       const Text(
//         'No matching journeys for this pickup, destination and departure.',
//       ),
//     ...matches.take(2).map(tripCard),
//     if (trips.any((trip) => trip.mine)) ...[
//       const SizedBox(height: 18),
//       const Heading('Your Posts'),
//       ...trips.where((trip) => trip.mine).map(tripCard),
//     ],
//     PrimaryAction(
//       profile.driver ? 'Offer a Ride' : 'Create Free Ride Request',
//       createTrip,
//     ),
//   ];
//
//   Widget shortcut(IconData icon, String label, VoidCallback action) => Column(
//     children: [
//       IconButton.filledTonal(
//         onPressed: action,
//         tooltip: label,
//         icon: Icon(icon, color: teal),
//       ),
//       const SizedBox(height: 4),
//       Text(label, textAlign: TextAlign.center),
//     ],
//   );
//
//   List<Widget> results() => [
//     Panel(
//       border: sand,
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         title: Text(when(journey)),
//         subtitle: Text('${journey.pickup} → ${journey.destination}'),
//         trailing: const Icon(Icons.edit_outlined),
//         onTap: editJourney,
//       ),
//     ),
//     DropdownButtonFormField<bool>(
//       isExpanded: true,
//       initialValue: closestFirst,
//       decoration: const InputDecoration(labelText: 'Sort'),
//       items: const [
//         DropdownMenuItem(value: true, child: Text('Closest departure match')),
//         DropdownMenuItem(value: false, child: Text('Earliest departure')),
//       ],
//       onChanged: (value) => setState(() => closestFirst = value!),
//     ),
//     const SizedBox(height: 18),
//     if (matches.isEmpty)
//       const Heading(
//         'No matching rides',
//         'Try changing your journey or add a preview example.',
//       ),
//     ...matches.map(tripCard),
//     PrimaryAction('Add Example Match', addExample, secondary: true),
//     if (!profile.driver && matches.isEmpty)
//       PrimaryAction('Create Free Ride Request', createTrip),
//   ];
//
//   List<Widget> messages() => [
//     TextField(
//       decoration: const InputDecoration(
//         labelText: 'Search conversations',
//         prefixIcon: Icon(Icons.search),
//       ),
//       onChanged: (value) => setState(() => search = value.trim().toLowerCase()),
//     ),
//     const SizedBox(height: 18),
//     if (!trips.any(canShowChat)) const Text('No conversations found.'),
//     ...trips
//         .where(canShowChat)
//         .map(
//           (trip) => ListTile(
//             leading: trip.vehicle == 'Car'
//                 ? const CircleAvatar(
//               backgroundColor: mint,
//               child: Icon(Icons.groups_outlined, color: forest),
//             )
//                 : const ProfileAvatar(),
//             title: Text(
//               trip.vehicle == 'Car'
//                   ? 'Journey Chat · ${trip.journey.destination}'
//                   : trip.host,
//             ),
//             subtitle: Text(
//               trip.messages.isEmpty
//                   ? 'Start a conversation'
//                   : trip.messages.last,
//             ),
//             onTap: () async {
//               await showPage(context, ChatPage(trip: trip));
//               if (mounted) setState(() {});
//             },
//           ),
//         ),
//   ];
//
//   bool canShowChat(PreviewTrip trip) {
//     if (trip.acceptedCarRide != null) return false;
//     if (blocked.contains(trip.host)) return false;
//
//     if (trip.status != TripStatus.accepted &&
//         trip.status != TripStatus.completed) {
//       return false;
//     }
//
//     final names = <String>[trip.host];
//     if (trip.vehicle == 'Car') {
//       names.addAll(['Journey Chat', trip.journey.destination, ...trip.members]);
//     }
//
//     return names.any((name) => name.toLowerCase().contains(search));
//   }
//
//   List<Widget> me() => [
//     Center(child: ProfileAvatar(photo: profile.photo, radius: 45)),
//     const SizedBox(height: 12),
//     Heading(profile.name, '$role · ${profile.section}', forest, true),
//     PrimaryAction('Edit Profile', () async {
//       await showPage(context, PreviewSetup(profile: profile));
//       if (mounted) setState(() {});
//     }),
//     ListTile(
//       leading: const Icon(Icons.place_outlined),
//       title: const Text('Address'),
//       onTap: editJourney,
//     ),
//     ListTile(
//       leading: const Icon(Icons.route_outlined),
//       title: const Text('My Journeys'),
//       onTap: showHistory,
//     ),
//     ListTile(
//       leading: const Icon(Icons.notifications_outlined),
//       title: const Text('Notifications'),
//       onTap: showNotifications,
//     ),
//     ListTile(
//       leading: const Icon(Icons.block),
//       title: const Text('Blocked Accounts'),
//       onTap: showBlocked,
//     ),
//     ListTile(
//       leading: const Icon(Icons.settings_outlined),
//       title: const Text('Settings'),
//       onTap: () => showPage(
//         context,
//         Screen(
//           title: 'Settings',
//           children: [
//             const Text('Frontend preview'),
//             PrimaryAction('Edit Journey', editJourney),
//             PrimaryAction('Logout', logout, secondary: true),
//           ],
//         ),
//       ),
//     ),
//     ListTile(
//       leading: const Icon(Icons.logout),
//       title: const Text('Logout'),
//       onTap: logout,
//     ),
//   ];
//
//   void logout() => Navigator.of(context).popUntil((route) => route.isFirst);
//
//   void showHistory() => showPage(
//     context,
//     StatefulBuilder(
//       builder: (context, refresh) => Screen(
//         title: 'Ride History',
//         children: [
//           SegmentedButton<bool>(
//             segments: const [
//               ButtonSegment(value: false, label: Text('Past')),
//               ButtonSegment(value: true, label: Text('Upcoming')),
//             ],
//             selected: {upcoming},
//             onSelectionChanged: (value) =>
//                 refresh(() => upcoming = value.first),
//           ),
//           const SizedBox(height: 16),
//           if (!trips.any(historyFilter)) const Text('No journeys to show.'),
//           ...trips
//               .where(historyFilter)
//               .map(
//                 (trip) => Panel(
//                   color: const Color(0xffeeeeee),
//                   child: ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: Text(
//                       '${trip.journey.pickup} → ${trip.journey.destination}',
//                     ),
//                     subtitle: Text(
//                       '${when(trip.journey)} · ${trip.status.name}',
//                     ),
//                     onTap: () async {
//                       await openTrip(trip);
//                       if (context.mounted) refresh(() {});
//                     },
//                   ),
//                 ),
//               ),
//         ],
//       ),
//     ),
//   );
//
//   bool historyFilter(PreviewTrip trip) {
//     if (blocked.contains(trip.host) ||
//         (!trip.mine && trip.status == TripStatus.available))
//       return false;
//     final isPast =
//         trip.status == TripStatus.completed ||
//         trip.status == TripStatus.declined ||
//         !trip.journey.departure.isAfter(DateTime.now());
//     return upcoming != isPast;
//   }
//
//   void showNotifications() => showPage(
//     context,
//     StatefulBuilder(
//       builder: (context, refresh) {
//         final visible = notifications.where(
//           (message) =>
//               notificationFilter == 'All' ||
//               (notificationFilter == 'Matches' &&
//                   !message.startsWith('Message')) ||
//               (notificationFilter == 'Messages' &&
//                   message.startsWith('Message')),
//         );
//         return Screen(
//           title: 'Notifications',
//           background: cream,
//           children: [
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: ['All', 'Matches', 'Messages']
//                   .map(
//                     (value) => ChoiceChip(
//                       label: Text(value),
//                       selected: notificationFilter == value,
//                       onSelected: (_) =>
//                           refresh(() => notificationFilter = value),
//                     ),
//                   )
//                   .toList(),
//             ),
//             const SizedBox(height: 16),
//             if (visible.isEmpty) const Text('You’re all caught up.'),
//             ...visible.map(
//               (message) => ListTile(
//                 leading: const Icon(Icons.notifications_outlined),
//                 title: Text(message),
//               ),
//             ),
//           ],
//         );
//       },
//     ),
//   );
//
//   void showBlocked() => showPage(
//     context,
//     StatefulBuilder(
//       builder: (context, refresh) => Screen(
//         title: 'Blocked Accounts',
//         background: lilac,
//         children: [
//           if (blocked.isEmpty) const Text('No blocked accounts.'),
//           for (final name in blocked)
//             ListTile(
//               leading: const ProfileAvatar(),
//               title: Text(name),
//               trailing: OutlinedButton(
//                 onPressed: () {
//                   setState(() => blocked.remove(name));
//                   refresh(() {});
//                 },
//                 child: const Text('Unblock'),
//               ),
//             ),
//           const SizedBox(height: 24),
//           const Panel(
//             color: Color(0xffeeeeee),
//             child: Text(
//               'Blocked accounts are hidden from matches, messages and ride history in this preview.',
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     title: ['яouto', 'Matches', 'Messages', 'Me'][tab],
//     background: [mint, Colors.white, cream, lilac][tab],
//     headerColor: tab == 0 ? teal : null,
//     drawer: tab == 0 ? Drawer(
//       backgroundColor: mint,
//       child: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(20),
//           children: me(),
//         ),
//       ),
//     ) : null,
//     actions: tab == 0 ? [
//       IconButton(
//         tooltip: 'Notifications',
//         onPressed: showNotifications,
//         icon: const Icon(Icons.notifications_outlined),
//       ),
//     ] : null,
//     footer: NavigationBar(
//       backgroundColor: tab == 0 ? const Color(0xffe2e5dc) : Colors.white,
//       indicatorColor: mint,
//       selectedIndex: tab,
//       onDestinationSelected: (i) => setState(() => tab = i),
//       destinations: const [
//         NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
//         NavigationDestination(
//           icon: Icon(Icons.group_outlined),
//           label: 'Matches',
//         ),
//         NavigationDestination(
//           icon: Icon(Icons.chat_bubble_outline),
//           label: 'Chat',
//         ),
//         NavigationDestination(icon: Icon(Icons.person_outline), label: 'Me'),
//       ],
//     ),
//     children: switch (tab) {
//       0 => home(),
//       1 => results(),
//       2 => messages(),
//       _ => me(),
//     },
//   );
// }

// class FarePage extends StatefulWidget {
//   const FarePage({super.key, required this.offering, required this.suggested});
//   final bool offering;
//   final double suggested;
//
//   @override
//   State<FarePage> createState() => _FarePageState();
// }
//
// class _FarePageState extends State<FarePage> {
//   final form = GlobalKey<FormState>();
//   final amount = TextEditingController();
//   bool contribute = false;
//
//   @override
//   void dispose() {
//     amount.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     background: lilac,
//     children: [
//       const SizedBox(height: 44),
//       Heading(
//         widget.offering
//             ? 'Set a Fare Contribution'
//             : 'How would you like to travel?',
//         null,
//         forest,
//         true,
//       ),
//       if (widget.suggested > 0)
//         Panel(
//           border: sand,
//           child: Center(
//             child: Heading(
//               'Rs. ${widget.suggested.toStringAsFixed(2)}',
//               'Suggested fare',
//               teal,
//               true,
//             ),
//           ),
//         ),
//       Panel(
//         border: sand,
//         color: lilac,
//         child: Column(
//           children: [
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               title: Text(
//                 widget.offering
//                     ? 'Offer the ride for free'
//                     : 'I’d like to travel for free',
//               ),
//               leading: Icon(
//                 contribute
//                     ? Icons.radio_button_unchecked
//                     : Icons.radio_button_checked,
//               ),
//               onTap: () => setState(() => contribute = false),
//             ),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               title: Text(
//                 widget.offering ? 'Suggest a contribution' : 'I’ll contribute',
//               ),
//               leading: Icon(
//                 contribute
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//               ),
//               onTap: () => setState(() => contribute = true),
//             ),
//             if (contribute)
//               Form(
//                 key: form,
//                 child: Field(
//                   'Amount (Rs.)',
//                   amount,
//                   keyboard: const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                   validator: (value) {
//                     final text = value?.trim() ?? '';
//                     final parsed = double.tryParse(text);
//                     return !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text) ||
//                             parsed == null ||
//                             !parsed.isFinite ||
//                             parsed <= 0
//                         ? 'Enter a positive amount with up to two decimal places'
//                         : null;
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//       PrimaryAction('Continue', () {
//         if (contribute && !form.currentState!.validate()) return;
//         Navigator.of(context)
//             .pop(contribute ? double.parse(amount.text.trim()) : 0.0);
//       }),
//     ],
//   );
// }

// class TripDetails extends StatefulWidget {
//   const TripDetails({
//     super.key,
//     required this.trip,
//     this.postedCar,
//     required this.profile,
//     required this.when,
//     required this.fareChoice,
//     required this.onUpdate,
//     required this.onBlock,
//   });
//   final PreviewTrip trip;
//   final PreviewTrip? postedCar;
//   final StudentProfile profile;
//   final String when;
//   final Future<double?> Function({required bool offering, double suggested})
//   fareChoice;
//   final ValueChanged<String> onUpdate;
//   final ValueChanged<String> onBlock;
//
//   @override
//   State<TripDetails> createState() => _TripDetailsState();
// }
//
// class _TripDetailsState extends State<TripDetails> {
//   PreviewTrip get trip => widget.trip.acceptedCarRide ?? widget.trip;
//   bool get isOpen => trip.journey.departure.isAfter(DateTime.now());
//   bool get canAct =>
//       isOpen &&
//       !trip.mine &&
//       trip.status == TripStatus.available &&
//       trip.seats > 0;
//   final comment = TextEditingController();
//
//   @override
//   void dispose() {
//     comment.dispose();
//     super.dispose();
//   }
//
//   void changeStatus(TripStatus status, String message) {
//     setState(() => trip.status = status);
//     widget.onUpdate(message);
//   }
//
//   Future<void> request() async {
//     if (!canAct || widget.profile.driver || trip.freeRequest) return;
//     final amount = await widget.fareChoice(
//       offering: false,
//       suggested: trip.fare,
//     );
//     if (!mounted || amount == null || !canAct) return;
//     trip.contribution = amount;
//     changeStatus(
//       TripStatus.pending,
//       'Preview request to join ${trip.host} sent.',
//     );
//   }
//   Future<void> previewDriverDecision() async {
//     if (trip.status != TripStatus.pending || !isOpen) return;
//
//     final passenger = widget.profile.name.trim();
//     if (passenger.isEmpty) {
//       notice(context, 'Add your name to your profile first.');
//       return;
//     }
//
//     final accepted = await showPage<bool>(
//       context,
//       Builder(
//         builder: (pageContext) => Screen(
//           title: 'Driver preview',
//           background: cream,
//           children: [
//             const Heading(
//               'Incoming ride request',
//               'Preview what the driver sees for this request.',
//             ),
//             Panel(
//               border: sand,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     leading: const CircleAvatar(
//                       backgroundColor: mint,
//                       child: Icon(Icons.person_outline, color: forest),
//                     ),
//                     title: Text(
//                       passenger,
//                       style: const TextStyle(fontWeight: FontWeight.w800),
//                     ),
//                     subtitle: Text('Wants to join ${trip.host}’s ride'),
//                   ),
//                   const Divider(),
//                   Text('${trip.journey.pickup} → ${trip.journey.destination}'),
//                   const SizedBox(height: 8),
//                   Text(widget.when),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Offered contribution · Rs. '
//                         '${trip.contribution.toStringAsFixed(2)}',
//                   ),
//                 ],
//               ),
//             ),
//             PrimaryAction(
//               'Accept request',
//               trip.seats > 0
//                   ? () => Navigator.of(pageContext).pop(true)
//                   : null,
//             ),
//             PrimaryAction(
//               'Reject request',
//                   () => Navigator.of(pageContext).pop(false),
//               secondary: true,
//             ),
//           ],
//         ),
//       ),
//     );
//
//     // Going back without choosing keeps the request pending.
//     if (!mounted || accepted == null || trip.status != TripStatus.pending) {
//       return;
//     }
//
//     if (!isOpen) {
//       notice(context, 'This ride has already departed.');
//       return;
//     }
//
//     if (!accepted) {
//       changeStatus(
//         TripStatus.declined,
//         '${trip.host} declined your ride request.',
//       );
//       return;
//     }
//
//     // The existing model adds the passenger and counts the occupied seat.
//     if (!trip.join(passenger)) {
//       notice(context, 'This passenger could not be added to the ride.');
//       return;
//     }
//
//     changeStatus(
//       TripStatus.accepted,
//       '${trip.host} accepted your request. Your journey chat is ready.',
//     );
//   }
//
//   void acceptPassenger() {
//     if (!canAct || !widget.profile.driver || !trip.freeRequest) return;
//
//     final request = widget.trip;
//
//     if (widget.profile.vehicle == 'Car') {
//       final car = widget.postedCar;
//
//       if (car == null) {
//         notice(context, 'Post your car ride for this journey first.');
//         return;
//       }
//
//       if (!car.journey.departure.isAfter(DateTime.now()) ||
//           car.status == TripStatus.completed ||
//           car.status == TripStatus.declined) {
//         notice(context, 'This car ride is no longer open.');
//         return;
//       }
//
//       if (car.members.contains(request.host)) {
//         notice(context, '${request.host} is already in this car.');
//         return;
//       }
//
//       if (!car.join(request.host)) {
//         notice(context, 'No passenger seats left in this car.');
//         return;
//       }
//
//       setState(() {
//         car.pendingMembers.remove(request.host);
//         car.status = TripStatus.accepted;
//         request.status = TripStatus.accepted;
//         request.acceptedCarRide = car;
//       });
//
//       widget.onUpdate('${request.host} joined your car ride.');
//       return;
//     }
//
//     // Existing bike and scooter flow.
//     if (!request.join(request.host)) return;
//     changeStatus(
//       TripStatus.accepted,
//       'You accepted ${request.host}’s preview ride request.',
//     );
//   }
//
//   Future<void> report() async {
//     final result = await showPage<String>(context, ReportPage(name: trip.host));
//     if (!mounted || result == null) return;
//     if (result == 'block') {
//       widget.onBlock(trip.host);
//       Navigator.of(context).pop();
//     } else {
//       notice(context, 'Report recorded for this preview session.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     title: 'Trip Details',
//     background: cream,
//     children: [
//       Panel(
//         color: const Color(0xffe4e8e2),
//         child: Row(
//           children: [
//             const ProfileAvatar(),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Heading(
//                 trip.host,
//                 trip.freeRequest
//                     ? 'Passenger · Free request'
//                     : 'Driver · ${trip.vehicle}',
//                 teal,
//               ),
//             ),
//           ],
//         ),
//       ),
//       Panel(
//         border: sand,
//         child: Column(
//           children: [
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.location_on_outlined),
//               title: Text(trip.journey.pickup),
//               subtitle: const Text('Starting point'),
//             ),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.school_outlined),
//               title: Text(trip.journey.destination),
//               subtitle: const Text('Destination'),
//             ),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.schedule),
//               title: Text(widget.when),
//               subtitle: Text(trip.status.name.toUpperCase()),
//             ),
//           ],
//         ),
//       ),
//       Panel(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Journey Group',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//             ),
//             const SizedBox(height: 8),
//             if (!trip.freeRequest ||
//                 trip.status == TripStatus.accepted ||
//                 trip.status == TripStatus.completed)
//               Text('${trip.seats} passenger seats available'),
//             Text(
//               trip.members.isEmpty
//                   ? 'No joined passengers'
//                   : trip.members.join(', '),
//             ),
//             if (trip.fare > 0)
//               Text('Suggested fare · Rs. ${trip.fare.toStringAsFixed(2)}'),
//             if (!trip.mine &&
//                 !trip.freeRequest &&
//                 trip.status != TripStatus.available)
//               Text(
//                 'Your contribution · Rs. ${trip.contribution.toStringAsFixed(2)}',
//               ),
//           ],
//         ),
//       ),
//       if (canAct && !widget.profile.driver && !trip.freeRequest)
//         PrimaryAction('Join Match', request),
//       if (canAct && widget.profile.driver && trip.freeRequest) ...[
//         PrimaryAction('Accept', acceptPassenger),
//         PrimaryAction(
//           'Reject',
//           () => changeStatus(
//             TripStatus.declined,
//             'You declined ${trip.host}’s preview request.',
//           ),
//           secondary: true,
//         ),
//       ],
//       if (widget.profile.driver && trip.mine && isOpen) ...[
//         const Heading('Incoming Requests'),
//         if (trip.pendingMembers.isEmpty) const Text('No pending requests.'),
//         for (final name in trip.pendingMembers)
//           Panel(
//             border: sand,
//             child: Column(
//               children: [
//                 Text(name),
//                 PrimaryAction(
//                   'Accept',
//                   trip.seats == 0
//                       ? null
//                       : () {
//                           if (!trip.acceptMember(name)) return;
//                           changeStatus(
//                             TripStatus.accepted,
//                             'You accepted $name.',
//                           );
//                         },
//                 ),
//                 PrimaryAction('Reject', () {
//                   setState(() => trip.pendingMembers.remove(name));
//                   widget.onUpdate('You declined $name.');
//                 }, secondary: true),
//               ],
//             ),
//           ),
//         PrimaryAction(
//           'Add Example Request',
//           trip.seats == 0
//               ? null
//               : () {
//                   final name = ['Erick', 'Evaa', 'Sunita', 'Alex'].firstWhere(
//                     (name) =>
//                         !trip.members.contains(name) &&
//                         !trip.pendingMembers.contains(name) &&
//                         name != trip.host,
//                     orElse: () => '',
//                   );
//                   if (name.isNotEmpty) {
//                     setState(() => trip.pendingMembers.add(name));
//                     widget.onUpdate(
//                       '$name requested to join your ride from '
//                           '${trip.journey.pickup} to ${trip.journey.destination}.',
//                     );
//                   }
//                 },
//           secondary: true,
//         ),
//       ],
//       if (trip.status == TripStatus.pending) ...[
//         const Panel(
//           child: Text('Your request is pending driver approval.'),
//         ),
//         if (!widget.profile.driver && !trip.mine && !trip.freeRequest && isOpen)
//           PrimaryAction(
//             'Preview driver response',
//             previewDriverDecision,
//             secondary: true,
//           ),
//       ],
//
//       if (trip.status == TripStatus.declined)
//         Panel(
//           border: sand,
//           child: Text('${trip.host} declined this ride request.'),
//         ),
//       if (trip.status == TripStatus.accepted) ...[
//         const Heading(
//           'You’re Connected!',
//           'Your preview ride was accepted.',
//           forest,
//           true,
//         ),
//         PrimaryAction(
//           'Open Chat',
//           () => showPage(
//             context,
//             ChatPage(trip: trip, onUpdate: widget.onUpdate),
//           ),
//         ),
//         if (widget.profile.driver)
//           PrimaryAction(
//             'Mark Ride Completed',
//             () => changeStatus(
//               TripStatus.completed,
//               'Your preview ride was completed.',
//             ),
//             secondary: true,
//           ),
//       ],
//       if (trip.status == TripStatus.completed && !trip.mine) ...[
//         PrimaryAction(
//           trip.stars == null ? 'Rate Your Ride' : 'Edit Review',
//           () async {
//             await showPage(context, ReviewPage(trip: trip));
//             if (mounted) setState(() {});
//           },
//         ),
//         const SizedBox(height: 20),
//         const Heading('Comments'),
//         for (final text in trip.comments) ListTile(title: Text(text)),
//         Field('Write a comment', comment, lines: 2),
//         PrimaryAction('Post Comment', () {
//           final text = comment.text.trim();
//           if (text.isEmpty) return;
//           setState(() {
//             trip.comments.add(text);
//             comment.clear();
//           });
//         }, secondary: true),
//       ],
//       if (!trip.mine)
//         TextButton(
//           onPressed: report,
//           child: const Text(
//             'Report or Block',
//             style: TextStyle(color: Colors.red),
//           ),
//         ),
//     ],
//   );
// }

// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key, required this.trip, this.onUpdate});
//   final PreviewTrip trip;
//   final ValueChanged<String>? onUpdate;
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   final message = TextEditingController();
//
//   @override
//   void dispose() {
//     message.dispose();
//     super.dispose();
//   }
//
//   void send() {
//     final text = message.text.trim();
//     if (text.isEmpty) return;
//     setState(() {
//       widget.trip.messages.add(text);
//       message.clear();
//     });
//     widget.onUpdate?.call('Message added to your preview journey chat.');
//   }
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     title: widget.trip.capacity > 1 ? 'Journey Chat' : widget.trip.host,
//     background: mint,
//     children: [
//       Panel(
//         border: sand,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'People in this ride',
//               style: TextStyle(
//                 color: forest,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 for (final name in {widget.trip.host, ...widget.trip.members})
//                   Chip(
//                     backgroundColor: mint,
//                     avatar: const Icon(
//                       Icons.person_outline,
//                       size: 18,
//                       color: forest,
//                     ),
//                     label: Text(name),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       if (widget.trip.messages.isEmpty)
//         const Text('Coordinate your meeting point here.'),
//       for (final text in widget.trip.messages)
//         Align(
//           alignment: Alignment.centerRight,
//           child: Panel(
//             color: const Color(0xffd4ded6),
//             padding: 12,
//             child: Text(text, style: const TextStyle(height: 1.4)),
//           ),
//         ),
//       const SizedBox(height: 12),
//       Field(
//         'Type a message…',
//         message,
//         suffix: IconButton(
//           tooltip: 'Send',
//           onPressed: send,
//           icon: const Icon(Icons.send_outlined),
//         ),
//       ),
//     ],
//   );
// }

// class ReviewPage extends StatefulWidget {
//   const ReviewPage({super.key, required this.trip});
//   final PreviewTrip trip;
//
//   @override
//   State<ReviewPage> createState() => _ReviewPageState();
// }
//
// class _ReviewPageState extends State<ReviewPage> {
//   late int stars = widget.trip.stars ?? 0;
//   final comment = TextEditingController();
//   bool submitted = false;
//
//   @override
//   void dispose() {
//     comment.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     title: 'Rate Your Ride',
//     background: lilac,
//     children: [
//       if (submitted) ...[
//         const Icon(Icons.check_circle, size: 96, color: forest),
//         const SizedBox(height: 18),
//         const Heading(
//           'Review Submitted',
//           'Thanks for sharing your experience.',
//           forest,
//           true,
//         ),
//         PrimaryAction('Done', () => Navigator.of(context).pop()),
//       ] else ...[
//         Heading('How was your ride with ${widget.trip.host}?'),
//         Wrap(
//           children: [
//             for (var value = 1; value <= 5; value++)
//               IconButton(
//                 tooltip: '$value stars',
//                 onPressed: () => setState(() => stars = value),
//                 icon: Icon(
//                   value <= stars ? Icons.star : Icons.star_border,
//                   color: const Color(0xffa86c00),
//                   size: 31,
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 24),
//         Field('Add a comment', comment, lines: 4),
//         PrimaryAction('Submit Review', () {
//           if (stars == 0) {
//             notice(context, 'Select a star rating.');
//             return;
//           }
//           setState(() {
//             widget.trip.stars = stars;
//             if (comment.text.trim().isNotEmpty)
//               widget.trip.comments.add(comment.text.trim());
//             submitted = true;
//           });
//         }),
//       ],
//     ],
//   );
// }

// class ReportPage extends StatefulWidget {
//   const ReportPage({super.key, required this.name});
//   final String name;
//
//   @override
//   State<ReportPage> createState() => _ReportPageState();
// }
//
// class _ReportPageState extends State<ReportPage> {
//   final details = TextEditingController();
//   String? reason;
//
//   @override
//   void dispose() {
//     details.dispose();
//     super.dispose();
//   }
//
//   Future<void> confirm(bool block) async {
//     if (!block &&
//         (reason == null ||
//             (reason == 'Other' && details.text.trim().isEmpty))) {
//       notice(context, 'Select a reason and add details if you choose Other.');
//       return;
//     }
//     final accepted = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
//         title: Text(block ? 'Block this User?' : 'Submit this Report?'),
//         content: const Text('This action applies to your preview session.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text(block ? 'Confirm' : 'Submit'),
//           ),
//         ],
//       ),
//     );
//     if (mounted && accepted == true)
//       Navigator.of(context).pop(block ? 'block' : 'report');
//   }
//
//   @override
//   Widget build(BuildContext context) => Screen(
//     title: 'Report ${widget.name}',
//     background: cream,
//     children: [
//       const Heading('What happened?'),
//       for (final value in [
//         'Unsafe Driving',
//         'Harassment',
//         'Inappropriate Behavior',
//         'Fake Information',
//         'Other',
//       ])
//         ListTile(
//           leading: Icon(
//             reason == value
//                 ? Icons.radio_button_checked
//                 : Icons.radio_button_unchecked,
//             color: Colors.red.shade800,
//           ),
//           title: Text(value),
//           onTap: () => setState(() => reason = value),
//         ),
//       const SizedBox(height: 12),
//       Field('Additional Details', details, lines: 3),
//       PrimaryAction('Submit Report', () => confirm(false)),
//       PrimaryAction(
//         'Block ${widget.name}',
//         () => confirm(true),
//         secondary: true,
//       ),
//     ],
//   );
// }
