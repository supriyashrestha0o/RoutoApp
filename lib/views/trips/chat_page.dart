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
    connect();
  }

  @override
  void dispose() {
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
      title: Text(widget.trip.capacity > 1 ? 'Journey Chat' : widget.trip.host),
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
