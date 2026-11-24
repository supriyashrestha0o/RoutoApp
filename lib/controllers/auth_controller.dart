import 'package:routo/models/student_profile.dart';
import 'package:routo/models/user_account.dart';

/// Keeps registered accounts and checks logins.
///
/// FRONTEND PREVIEW ONLY: accounts live in memory, so they disappear when
/// the app is fully restarted, and passwords are kept as plain text.
/// Replace this with Firebase Auth / your backend before release.
class AuthController {
  AuthController._();

  static final Map<String, UserAccount> _accounts = {};

  /// Account whose profile still has to be saved (just registered, or
  /// logged in before finishing setup).
  static String? _pendingKey;

  static String _key(String email) => email.trim().toLowerCase();

  static bool exists(String email) => _accounts.containsKey(_key(email));

  /// Saves the email + password created during sign up.
  static void register(String email, String password) {
    final key = _key(email);
    _accounts[key] = UserAccount(email: email.trim(), password: password);
    _pendingKey = key;
  }

  /// Returns the account when email AND password match, otherwise null.
  static UserAccount? login(String email, String password) {
    final key = _key(email);
    final account = _accounts[key];
    if (account == null || account.password != password) return null;
    final unfinished = account.profile == null || account.profile!.journey == null;
    _pendingKey = unfinished ? key : null;
    return account;
  }

  /// Called when setup finishes: links the finished profile to the account.
  static void attachProfile(StudentProfile profile) {
    final account = _accounts[_pendingKey];
    if (account == null) return;
    account.profile = profile;
    _pendingKey = null;
  }
}
