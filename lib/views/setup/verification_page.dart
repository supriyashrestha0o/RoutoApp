import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/setup/setup_complete.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, required this.profile});

  final StudentProfile profile;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  static const requiredImages = 2;
  static final licensePattern = RegExp(r'^[0-9]{2}-[0-9]{2}-[0-9]{8}$');

  final form = GlobalKey<FormState>();

  late final license = TextEditingController(
    text: widget.profile.licenseNumber,
  );
  late final citizenship = TextEditingController(
    text: widget.profile.citizenshipNumber,
  );

  late List<String> licensePaths = List.of(widget.profile.licenseImagePaths);
  late List<String> citizenshipPaths =
  List.of(widget.profile.citizenshipImagePaths);

  @override
  void dispose() {
    license.dispose();
    citizenship.dispose();
    super.dispose();
  }

  Future<List<String>> pickImages() async {
    try {
      final files = await ImagePicker().pickMultiImage(imageQuality: 85);

      if (!mounted || files.isEmpty) return [];

      if (files.length != requiredImages) {
        notice(
          context,
          'You selected ${files.length}. Choose exactly 2 photos '
              '(front and back).',
        );
        return [];
      }

      return files.map((file) => file.path).toList();
    } catch (_) {
      if (mounted) {
        notice(context, 'Could not open photos. Please try again.');
      }
      return [];
    }
  }

  Future<void> chooseLicense() async {
    final paths = await pickImages();
    if (mounted && paths.isNotEmpty) {
      setState(() => licensePaths = paths);
    }
  }

  Future<void> chooseCitizenship() async {
    final paths = await pickImages();
    if (mounted && paths.isNotEmpty) {
      setState(() => citizenshipPaths = paths);
    }
  }

  String? validateLicenseNumber(String? value) {
    final number = value?.trim() ?? '';

    if (number.isEmpty) return 'Please enter your license number';

    if (!licensePattern.hasMatch(number)) {
      return 'Use the format XX-XX-XXXXXXXX.';
    }

    return null;
  }
  String? validateCitizenshipNumber(String? value) {
    final number = value?.trim() ?? '';

    if (number.isEmpty) return 'Please enter your citizenship number.';

    if (!RegExp(r'^[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{5}$').hasMatch(number)) {
      return 'Use the format XX-XX-XX-XXXXX.';
    }

    return null;
  }

  void submit() {
    if (!form.currentState!.validate()) return;

    if (licensePaths.length != requiredImages) {
      notice(
        context,
        'Select exactly 2 photos of your driving license (front and back).',
      );
      return;
    }

    if (citizenshipPaths.length != requiredImages) {
      notice(
        context,
        'Select exactly 2 photos of your citizenship (front and back).',
      );
      return;
    }

    widget.profile
      ..licenseNumber = license.text.trim()
      ..licenseImagePaths = licensePaths
      ..citizenshipNumber = citizenship.text.trim()
      ..citizenshipImagePaths = citizenshipPaths;

    showPage(context, SetupComplete(profile: widget.profile));
  }

  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: teal,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget numberField(
      TextEditingController controller,
      FormFieldValidator<String> validator,
      ) => TextFormField(
    controller: controller,
    validator: validator,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: teal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    ),
  );

  Widget uploadCard({
    required IconData icon,
    required String title,
    required List<String> paths,
    required VoidCallback onChoose,
  }) {
    final done = paths.length == requiredImages;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: done ? teal : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: sand,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: sand,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  paths.isEmpty
                      ? '(Front & Back)'
                      : '${paths.length} of $requiredImages photos selected',
                  style: TextStyle(
                    color: done ? forest : Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onChoose,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffe6e6e6),
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(paths.isEmpty ? 'Choose File' : 'Change File'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: 4,
    children: [
      const Heading(
        'Verification Documents',
        'Upload your driving license and citizenship for verification',
      ),
      const SizedBox(height: 16),
      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            label('Driving License'),
            uploadCard(
              icon: Icons.badge_outlined,
              title: 'Upload License',
              paths: licensePaths,
              onChoose: chooseLicense,
            ),
            const SizedBox(height: 16),
            label('License Number'),
            numberField(license, validateLicenseNumber),
            const SizedBox(height: 24),
            label('Citizenship'),
            uploadCard(
              icon: Icons.assignment_ind_outlined,
              title: 'Upload Citizenship',
              paths: citizenshipPaths,
              onChoose: chooseCitizenship,
            ),
            const SizedBox(height: 16),
            label('Citizenship Number'),
            numberField(citizenship, validateCitizenshipNumber),
          ],
        ),
      ),
      const SizedBox(height: 24),
      PrimaryAction('Submit for Verification', submit),
    ],
  );
}