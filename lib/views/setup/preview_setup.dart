import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:routo/controllers/validators.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/setup/journey_setup.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/profile_avatar.dart';
import 'package:routo/views/widgets/screen.dart';

class PreviewSetup extends StatefulWidget {
  const PreviewSetup({super.key, this.profile});
  final StudentProfile? profile;

  @override
  State<PreviewSetup> createState() => _PreviewSetupState();
}

class _PreviewSetupState extends State<PreviewSetup> {
  static const genders = ['Male', 'Female', 'Other'];

  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.profile?.name);
  late final age = TextEditingController(text: widget.profile?.age.toString());

  // No default: the user must choose a section and a gender.
  late String? section = (widget.profile?.section.isEmpty ?? true)
      ? null
      : widget.profile!.section;
  late String gender = widget.profile?.gender ?? '';
  late Uint8List? photo = widget.profile?.photo;

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 85,
      );
      final bytes = await file?.readAsBytes();
      if (mounted && bytes != null) setState(() => photo = bytes);
    } catch (_) {
      if (mounted) notice(context, 'Could not open photos. Please try again.');
    }
  }

  void save() {
    final formOk = form.currentState!.validate();
    if (gender.isEmpty) {
      notice(context, 'Please select your gender.');
      return;
    }
    if (!formOk) return;
    final profile = widget.profile ?? StudentProfile();
    profile
      ..name = name.text.trim()
      ..age = int.parse(age.text.trim())
      ..section = section ?? ''
      ..gender = gender
      ..photo = photo;
    if (widget.profile != null) {
      Navigator.of(context).pop();
      return;
    }
    showPage(context, JourneySetup(profile: profile));
  }

  Widget genderSelector() => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(color: forest, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 20,
          children: [
            for (final option in genders)
              InkWell(
                onTap: () => setState(() => gender = option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        gender == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: gender == option ? teal : sand,
                      ),
                      const SizedBox(width: 6),
                      Text(option),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: widget.profile == null ? 1 : null,
    children: [
      Heading(
        widget.profile == null ? 'Create Your Profile' : 'Edit Profile',
        'Tell us a little about yourself.',
      ),
      Center(
        child: InkWell(
          onTap: pickPhoto,
          child: Column(
            children: [
              ProfileAvatar(
                photo: photo,
                radius: 51,
                fallback: Icons.camera_alt_outlined,
              ),
              const SizedBox(height: 8),
              Text(photo == null ? 'Add Photo' : 'Change Photo'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      Form(
        key: form,
        child: Column(
          children: [
            Field(
              'Full Name',
              name,
              icon: Icons.person_outline,
              validator: requiredField,
            ),
            DropdownButtonFormField<String>(
              initialValue: section,
              decoration: const InputDecoration(labelText: 'Section'),
              items: [
                'Section A',
                'Section B',
                'Section C',
                'Other',
              ].map(option).toList(),
              validator: (value) =>
              value == null ? 'Please choose a section' : null,
              onChanged: (value) => setState(() => section = value),
            ),
            const SizedBox(height: 14),
            Field(
              'Age',
              age,
              icon: Icons.calendar_today_outlined,
              keyboard: TextInputType.number,
              validator: validAge,
            ),
            genderSelector(),
          ],
        ),
      ),
      PrimaryAction(widget.profile == null ? 'Continue' : 'Save Profile', save),
    ],
  );
}
