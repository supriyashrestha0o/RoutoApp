import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class EmailCodeService {
  static const _serviceId = 'service_uy0hemg';
  static const _templateId = 'template_d0pg9wn';
  static const _publicKey = 'vNHUmcxcrmwzYGDmX';

  final _col = FirebaseFirestore.instance.collection('email_codes');

  /// Generates a random 6-digit code, saves it, and emails it.
  Future<void> sendCode(String email) async {
    final id = email.toLowerCase().trim();
    final code = (100000 + Random.secure().nextInt(900000)).toString();

    await _col.doc(id).set({
      'code': code,
      'expiresAt': DateTime.now().millisecondsSinceEpoch + 5 * 60 * 1000,
      'attempts': 0,
    });

    final res = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'template_params': {'to_email': id, 'code': code},
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Email failed: ${res.body}');
    }
  }

  /// True only if the code is correct, not expired, and under 5 attempts.
  Future<bool> verifyCode(String email, String entered) async {
    final ref = _col.doc(email.toLowerCase().trim());
    final snap = await ref.get();
    if (!snap.exists) return false;

    final data = snap.data()!;
    final expired =
        DateTime.now().millisecondsSinceEpoch > (data['expiresAt'] as int);
    if (expired || (data['attempts'] as int) >= 5) return false;

    if (data['code'] != entered.trim()) {
      await ref.update({'attempts': FieldValue.increment(1)});
      return false;
    }

    await ref.delete(); // one-time use
    return true;
  }
}