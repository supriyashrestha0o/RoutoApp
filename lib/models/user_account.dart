import 'package:routo/models/student_profile.dart';

/// One registered user: the credentials created on the
/// "Create Your Account" screen plus the profile built during setup.
class UserAccount {
  UserAccount({required this.email, required this.password, this.profile});

  final String email;
  String password;
  StudentProfile? profile;
}
