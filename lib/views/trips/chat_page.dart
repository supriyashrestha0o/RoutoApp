import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/models/preview_trip.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/screen.dart';
import 'package:routo/core/ride_notifications.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.trip, this.onUpdate});
  final PreviewTrip trip;
  final ValueChanged<String>? onUpdate;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final message = TextEditingController();

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  void send() {
    final text = message.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.trip.messages.add(text);
      message.clear();
    });
    widget.onUpdate?.call('Message added to your preview journey chat.');
  }

  @override
  Widget build(BuildContext context) => Screen(
    title: widget.trip.capacity > 1 ? 'Journey Chat' : widget.trip.host,
    background: mint,
    children: [
      Panel(
        border: sand,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'People in this ride',
              style: TextStyle(
                color: forest,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
          ],
        ),
      ),
      if (widget.trip.messages.isEmpty)
        const Text('Coordinate your meeting point here.'),
      for (final text in widget.trip.messages)
        Align(
          alignment: Alignment.centerRight,
          child: Panel(
            color: const Color(0xffd4ded6),
            padding: 12,
            child: Text(text, style: const TextStyle(height: 1.4)),
          ),
        ),
      const SizedBox(height: 12),
      Field(
        'Type a message…',
        message,
        suffix: IconButton(
          tooltip: 'Send',
          onPressed: send,
          icon: const Icon(Icons.send_outlined),
        ),
      ),
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
    ],
  );
}