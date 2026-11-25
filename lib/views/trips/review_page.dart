import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/preview_trip.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({
    super.key,
    required this.trip,
    this.onCommentPosted,
  });

  final PreviewTrip trip;
  final ValueChanged<int>? onCommentPosted;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late int stars = widget.trip.stars ?? 0;
  final comment = TextEditingController();
  bool submitted = false;

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(
    title: 'Rate Your Ride',
    background: lilac,
    children: [
      if (submitted) ...[
        const Icon(Icons.check_circle, size: 96, color: forest),
        const SizedBox(height: 18),
        const Heading(
          'Review Submitted',
          'Thanks for sharing your experience.',
          forest,
          true,
        ),
        PrimaryAction('Done', () => Navigator.of(context).pop()),
      ] else ...[
        Heading(
          widget.trip.mine
              ? 'How was your ride?'
              : 'How was your ride with ${widget.trip.host}?',
        ),
        Wrap(
          children: [
            for (var value = 1; value <= 5; value++)
              IconButton(
                tooltip: '$value stars',
                onPressed: () => setState(() => stars = value),
                icon: Icon(
                  value <= stars ? Icons.star : Icons.star_border,
                  color: const Color(0xffa86c00),
                  size: 31,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Field('Add a comment', comment, lines: 4),
        PrimaryAction('Submit Review', () {
          if (stars == 0) {
            notice(context, 'Select a star rating.');
            return;
          }

          widget.trip.stars = stars;

          final text = comment.text.trim();
          if (text.isNotEmpty) {
            final index = widget.trip.comments.length;
            widget.trip.comments.add(text);
            widget.onCommentPosted?.call(index);
          }

          setState(() => submitted = true);
        }),
      ],
    ],
  );
}