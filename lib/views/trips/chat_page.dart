import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:routo/core/ride_notifications.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/preview_trip.dart';
import 'package:routo/views/widgets/panel.dart';

/// One chat message as stored in Firestore.
class _Message {
  const _Message({
    required this.text,
    required this.senderId,
    required this.senderName,
    this.sentAt,
  });

  final String text;
  final String senderId;
  final String senderName;

  /// Null for a moment after sending, until the server stamps the time.
  final DateTime? sentAt;

  factory _Message.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final sent = data['createdAt'];
    return _Message(
      text: (data['text'] as String?) ?? '',
      senderId: (data['senderId'] as String?) ?? '',
      senderName: (data['senderName'] as String?) ?? 'Student',
      sentAt: sent is Timestamp ? sent.toDate() : null,
    );
  }
}

/// Everything that talks to Firebase lives here, away from the widgets.
///
/// Firestore layout:
///   chats/{roomId}/messages/{autoId}
///     text: String, senderId: String, senderName: String,
///     createdAt: server timestamp
class _ChatBackend {
  _ChatBackend._();

  static Future<User>? _session;

  /// Starts Firebase (once) and signs the phone in anonymously, which gives
  /// every device a stable id (uid) that tells "my" messages from "theirs".
  static Future<User> signIn() async {
    try {
      final pending = _session ??= _connect();
      return await pending;
    } catch (_) {
      _session = null; // let "Try again" start from scratch
      rethrow;
    }
  }

  static Future<User> _connect() async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    final auth = FirebaseAuth.instance;
    final existing = auth.currentUser;
    if (existing != null) return existing;
    final credential = await auth.signInAnonymously();
    return credential.user!;
  }

  /// Same trip data -> same room id on every phone.
  static String roomId(PreviewTrip trip) {
    final journey = trip.journey;
    final minute = journey.departure.toUtc().millisecondsSinceEpoch ~/ 60000;
    final raw =
        '${trip.host}_${journey.pickup}_${journey.destination}_$minute';
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '_');
  }

  static CollectionReference<Map<String, dynamic>> messages(String room) =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(room)
          .collection('messages');
}

class _RoomWatch {
  _RoomWatch(this.trip);
  PreviewTrip trip;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
  String? lastId;
  bool ready = false;
}

/// Pops up a notification when a new message arrives in any accepted chat,
/// even when that chat is not open. The dashboard starts it with [watch] and
/// ends it with [stop]. Works while the app is open or still alive in the
/// background; a closed app needs push notifications (FCM) instead.
class ChatAlerts {
  ChatAlerts._();

  /// Room of the chat page that is on screen right now (no popup needed).
  static String? openRoom;

  static final _rooms = <String, _RoomWatch>{};
  static void Function(String? notification)? _onChange;

  /// Safe to call on every rebuild: only new rooms start listening.
  static void watch(
      Iterable<PreviewTrip> trips, {
        Set<String> blocked = const {},
        void Function(String? notification)? onChange,
      }) {
    _onChange = onChange;
    final wanted = <String, PreviewTrip>{};
    for (final trip in trips) {
      final hasChat =
          trip.acceptedCarRide == null &&
              !blocked.contains(trip.host) &&
              (trip.status == TripStatus.accepted ||
                  trip.status == TripStatus.completed);
      if (hasChat) wanted[_ChatBackend.roomId(trip)] = trip;
    }
    for (final room in _rooms.keys.toList()) {
      if (!wanted.containsKey(room)) {
        _rooms.remove(room)?.subscription?.cancel();
      }
    }
    wanted.forEach((room, trip) {
      final existing = _rooms[room];
      if (existing != null) {
        existing.trip = trip;
        return;
      }
      final watch = _rooms[room] = _RoomWatch(trip);
      _start(room, watch);
    });
  }

  static Future<void> _start(String room, _RoomWatch watch) async {
    try {
      final user = await _ChatBackend.signIn();
      if (_rooms[room] != watch) return; // stopped or no longer wanted
      watch.subscription = _ChatBackend.messages(room)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .listen(
            (snapshot) => _onSnapshot(room, watch, user.uid, snapshot),
        onError: (Object e) => debugPrint('Chat alerts: $e'),
      );
    } catch (e) {
      // Retried automatically the next time the dashboard rebuilds.
      if (_rooms[room] == watch) _rooms.remove(room);
      debugPrint('Chat alerts could not start: $e');
    }
  }

  static void _onSnapshot(
      String room,
      _RoomWatch watch,
      String uid,
      QuerySnapshot<Map<String, dynamic>> snapshot,
      ) {
    if (snapshot.docs.isEmpty) {
      watch.ready = true;
      return;
    }
    final doc = snapshot.docs.first;
    if (doc.id == watch.lastId) return; // nothing new
    final message = _Message.fromDoc(doc);
    final firstLook = !watch.ready;
    watch.ready = true;
    watch.lastId = doc.id;

    final chatIsOpen = openRoom == room;
    // Keeps the dashboard's Messages tab preview up to date.
    if (!chatIsOpen) {
      watch.trip.messages
        ..clear()
        ..add(message.text);
    }
    // Never pop up for old messages, my own, or the chat I'm looking at.
    final incoming = !firstLook && message.senderId != uid && !chatIsOpen;
    if (incoming) {
      unawaited(RideNotifications.showUpdate(message.senderName, message.text));
    }
    _onChange?.call(
      incoming ? 'Message from ${message.senderName}: ${message.text}' : null,
    );
  }

  static void stop() {
    for (final watch in _rooms.values) {
      watch.subscription?.cancel();
    }
    _rooms.clear();
    _onChange = null;
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.trip,
    this.onUpdate,
    this.senderName,
  });
  final PreviewTrip trip;
  final ValueChanged<String>? onUpdate;

  /// Name shown on this user's messages. Optional: when it is not passed the
  /// chat uses the trip host for your own trips and "Student xxxx" otherwise.
  final String? senderName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final message = TextEditingController();
  late final String room = _ChatBackend.roomId(widget.trip);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;
  String? uid;
  Object? error;

  /// Newest first (the list below is drawn upside down so it stays pinned to
  /// the latest message without any scroll controller).
  List<_Message> messages = const [];

  @override
  void initState() {
    super.initState();
    ChatAlerts.openRoom = room; // no popups for the chat on screen
    connect();
  }

  @override
  void dispose() {
    if (ChatAlerts.openRoom == room) ChatAlerts.openRoom = null;
    subscription?.cancel();
    message.dispose();
    super.dispose();
  }

  Future<void> connect() async {
    try {
      final user = await _ChatBackend.signIn().timeout(
        const Duration(seconds: 20),
      );
      if (!mounted) return;
      await subscription?.cancel();
      subscription = _ChatBackend.messages(room)
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots()
          .listen(onSnapshot, onError: showError);
      setState(() => uid = user.uid);
    } catch (e) {
      showError(e);
    }
  }

  void showError(Object e) {
    if (mounted) setState(() => error = e);
  }

  void retry() {
    setState(() {
      error = null;
      uid = null;
    });
    connect();
  }

  void onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final latestFirst = snapshot.docs.map(_Message.fromDoc).toList();
    // The dashboard's Messages tab reads trip.messages.last as its preview,
    // so keep that list in step with what Firestore says.
    widget.trip.messages
      ..clear()
      ..addAll(latestFirst.reversed.map((m) => m.text));
    if (mounted) setState(() => messages = latestFirst);
  }

  /// One-to-one chats show the other person's name; a group (more than one
  /// passenger) shows "Journey Chat".
  String get title {
    final trip = widget.trip;
    if (trip.members.length > 1) return 'Journey Chat';
    if (!trip.mine) return trip.host;
    return trip.members.isEmpty ? 'Journey Chat' : trip.members.first;
  }

  String get senderName =>
      widget.senderName ??
          (widget.trip.mine
              ? widget.trip.host
              : 'Student ${uid!.substring(0, 4)}');

  Future<void> send() async {
    final text = message.text.trim();
    if (text.isEmpty || uid == null) return;
    message.clear();
    widget.onUpdate?.call('Message sent in your journey chat.');
    try {
      await _ChatBackend.messages(room).add({
        'text': text,
        'senderId': uid,
        'senderName': senderName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (mounted) notice(context, 'Message could not be sent. Try again.');
    }
  }

  Widget people() => Panel(
    border: sand,
    padding: 12,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'People in this ride',
          style: TextStyle(
            color: forest,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            children: [
              for (final name in {widget.trip.host, ...widget.trip.members})
                Chip(
                  backgroundColor: mint,
                  avatar: const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: forest,
                  ),
                  label: Text(name),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget bubble(_Message item) {
    final mine = item.senderId == uid;
    final sentAt = item.sentAt;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .75,
        ),
        decoration: BoxDecoration(
          color: mine ? const Color(0xffd4ded6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 3),
            bottomRight: Radius.circular(mine ? 3 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mine)
              Text(
                item.senderName,
                style: const TextStyle(
                  color: teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(item.text, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                sentAt == null
                    ? 'Sending…'
                    : TimeOfDay.fromDateTime(sentAt).format(context),
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget conversation() => messages.isEmpty
      ? const Center(child: Text('Coordinate your meeting point here.'))
      : ListView.builder(
    reverse: true,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: messages.length,
    itemBuilder: (_, index) => bubble(messages[index]),
  );

  Widget composer() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: message,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Type a message…',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton.filled(
          tooltip: 'Send',
          onPressed: send,
          icon: const Icon(Icons.send),
        ),
      ],
    ),
  );

  Widget failure() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: forest),
          const SizedBox(height: 12),
          const Text(
            'Chat could not connect',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your internet connection and the Firebase setup.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          TextButton(onPressed: retry, child: const Text('Try again')),
        ],
      ),
    ),
  );

  Widget content() {
    if (error != null) return failure();
    if (uid == null) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: people(),
        ),
        Expanded(child: conversation()),
        if (const bool.fromEnvironment('TEST_MESSAGE_POPUP'))
          TextButton(
            onPressed: () async {
              await RideNotifications.showUpdate(
                'New message from Sunita',
                'I’m at the pickup point.',
              );
            },
            child: const Text('Test incoming message'),
          ),
        composer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: mint,
    appBar: AppBar(
      title: Text(title),
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: content(),
        ),
      ),
    ),
  );
}
