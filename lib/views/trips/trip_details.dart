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

// The trip stores each top-level comment's text in trip.comments.
// Keep its display details with the same trip for this frontend session.
class _CommentDetails {
  _CommentDetails({this.author});

  final String? author;
  final List<_CommentReply> replies = [];
  final Set<StudentProfile> likedBy = Set<StudentProfile>.identity();
  final Set<StudentProfile> hiddenBy = Set<StudentProfile>.identity();
}

class _CommentReply {
  const _CommentReply(this.author, this.text);

  final String author;
  final String text;
}

class _TripDetailsState extends State<TripDetails> {
  static final _detailsByTrip = Expando<Map<int, _CommentDetails>>();

  PreviewTrip get trip => widget.trip.acceptedCarRide ?? widget.trip;
  bool get isOpen => trip.journey.departure.isAfter(DateTime.now());

  bool get canAct =>
      isOpen &&
          !trip.mine &&
          trip.status == TripStatus.available &&
          trip.seats > 0;

  final comment = TextEditingController();
  final _composerKey = GlobalKey();
  int? _replyingTo;

  Map<int, _CommentDetails> get _commentDetails =>
      _detailsByTrip[trip] ??= <int, _CommentDetails>{};

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

    final requestedTrip = trip;
    final passenger = widget.profile.name.trim();
    final onUpdate = widget.onUpdate;

    if (passenger.isEmpty) {
      notice(context, 'Add your name to your profile first.');
      return;
    }

    requestedTrip.contribution = amount;
    changeStatus(
      TripStatus.pending,
      'Preview request to join ${requestedTrip.host} sent.',
    );

    Future<void> simulateDriverReply() async {
      await Future<void>.delayed(const Duration(seconds: 5));

      if (requestedTrip.status != TripStatus.pending) return;

      final accepted =
          requestedTrip.journey.departure.isAfter(DateTime.now()) &&
              requestedTrip.join(passenger);

      requestedTrip.status =
      accepted ? TripStatus.accepted : TripStatus.declined;

      if (mounted) setState(() {});

      final message = accepted
          ? '${requestedTrip.host} accepted your request. Your journey chat is ready.'
          : '${requestedTrip.host} could not accept your request.';

      onUpdate(message);
      await RideNotifications.showUpdate(
        accepted ? 'Request accepted' : 'Request declined',
        message,
      );
    }

    await Future.wait<void>([
      simulateDriverReply(),
      RideNotifications.showRequestSent(),
    ]);
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
      await RideNotifications.showUpdate(
        'Request accepted',
        '${request.host} joined your car ride.',
      );
      return;
    }

    // Existing bike and scooter flow.
    if (!request.join(request.host)) return;
    changeStatus(
      TripStatus.accepted,
      'You accepted ${request.host}’s preview ride request.',
    );
    await RideNotifications.showUpdate(
      'Request accepted',
      'You accepted ${request.host}’s ride request.',
    );
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

  Future<void> _openReview() async {
    final author = widget.profile.name.trim();
    if (author.isEmpty) {
      notice(context, 'Add your name to your profile first.');
      return;
    }

    final details = _commentDetails;
    await showPage(
      context,
      ReviewPage(
        trip: trip,
        onCommentPosted: (index) {
          details[index] = _CommentDetails(author: author);
        },
      ),
    );

    if (mounted) setState(() {});
  }

  void _postComment() {
    final text = comment.text.trim();
    if (text.isEmpty) return;

    final author = widget.profile.name.trim();
    if (author.isEmpty) {
      notice(context, 'Add your name to your profile first.');
      return;
    }

    final replyIndex = _replyingTo;

    setState(() {
      if (replyIndex == null) {
        final index = trip.comments.length;
        trip.comments.add(text);
        _commentDetails[index] = _CommentDetails(author: author);
      } else {
        _commentDetails[replyIndex]!.replies.add(_CommentReply(author, text));
      }

      _replyingTo = null;
      comment.clear();
    });

    FocusScope.of(context).unfocus();
  }

  void _startReply(int index) {
    setState(() => _replyingTo = index);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final composer = _composerKey.currentContext;
      if (composer != null) {
        Scrollable.ensureVisible(
          composer,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  Widget _commentAvatar(String? name, {double radius = 18}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: mint,
      child: name == null || name.isEmpty
          ? Icon(Icons.person_outline, color: forest, size: radius)
          : Text(
        name.characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: radius,
          color: forest,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildComment(int index) {
    final details = _commentDetails.putIfAbsent(index, () => _CommentDetails());
    final viewer = widget.profile;
    final hidden = details.hiddenBy.contains(viewer);
    final liked = details.likedBy.contains(viewer);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _commentAvatar(details.author),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.author != null)
                  Text(
                    details.author!,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                const SizedBox(height: 3),
                Text(hidden ? 'Comment hidden' : trip.comments[index]),
                Wrap(
                  children: [
                    if (!hidden)
                      TextButton(
                        onPressed: () => _startReply(index),
                        child: const Text('Reply'),
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (hidden) {
                            details.hiddenBy.remove(viewer);
                          } else {
                            details.hiddenBy.add(viewer);
                            if (_replyingTo == index) _replyingTo = null;
                          }
                        });
                      },
                      child: Text(hidden ? 'Show' : 'Hide'),
                    ),
                  ],
                ),
                if (!hidden)
                  for (final reply in details.replies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _commentAvatar(reply.author, radius: 13),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reply.author,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(reply.text),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          if (!hidden)
            IconButton(
              tooltip: liked ? 'Remove like' : 'Like comment',
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? teal : Colors.black54,
                size: 21,
              ),
              onPressed: () {
                setState(() {
                  if (liked) {
                    details.likedBy.remove(viewer);
                  } else {
                    details.likedBy.add(viewer);
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    final replyIndex = _replyingTo;
    final replyAuthor =
    replyIndex == null ? null : _commentDetails[replyIndex]?.author;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Heading('Comments'),
        const SizedBox(height: 8),
        for (var i = 0; i < trip.comments.length; i++) _buildComment(i),
        Column(
          key: _composerKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (replyIndex != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      replyAuthor == null
                          ? 'Replying to this comment'
                          : 'Replying to $replyAuthor',
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _replyingTo = null),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            Field(
              replyIndex == null ? 'Write a comment' : 'Write a reply',
              comment,
              lines: 2,
            ),
            const SizedBox(height: 12),
            PrimaryAction(
              replyIndex == null ? 'Post Comment' : 'Post Reply',
              _postComment,
              secondary: true,
            ),
          ],
        ),
      ],
    );
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
            changeStatus(
              TripStatus.declined,
              'You declined $host’s preview request.',
            );
            await RideNotifications.showUpdate(
              'Request declined',
              'You declined $host’s ride request.',
            );
          },
          secondary: true,
        ),
      ],
      if (widget.profile.driver &&
          trip.mine &&
          isOpen &&
          trip.status != TripStatus.completed) ...[
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
                    await RideNotifications.showUpdate(
                      'Request accepted',
                      'You accepted $name.',
                    );
                  },
                ),
                PrimaryAction(
                  'Reject',
                      () async {
                    setState(() => trip.pendingMembers.remove(name));
                    widget.onUpdate('You declined $name.');
                    await RideNotifications.showUpdate(
                      'Request declined',
                      'You declined $name.',
                    );
                  },
                  secondary: true,
                ),
              ],
            ),
          ),
        PrimaryAction(
          'Add Example Request',
          trip.seats == 0
              ? null
              : () {
            final name =
            ['Erick', 'Evaa', 'Sunita', 'Alex'].firstWhere(
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
          ),
      ],
      if (trip.status == TripStatus.completed) ...[
        PrimaryAction(
          trip.stars == null ? 'Rate Your Ride' : 'Edit Review',
          _openReview,
        ),
        const SizedBox(height: 20),
        _buildComments(),
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