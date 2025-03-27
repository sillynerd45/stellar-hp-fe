import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class HashService {
  String generate({
    required String publicKey,
  }) {
    // Combine all inputs into a single string
    String input = publicKey.toLowerCase() + DateTime.now().toIso8601String() + randomString(10);

    // Convert to bytes and generate SHA-256 hash
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);

    // Truncate the hash to a maximum of 32 characters
    return digest.toString().substring(8, 40);
  }

  String randomString(int length,
      {bool includeLetters = true, bool includeNumbers = true, bool includeSpecialChars = false}) {
    // Define character sets
    const String letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const String numbers = "0123456789";
    const String specialChars = "!@#\$%^&*()_+-=[]{}|;:,.<>?";

    // Build allowed characters based on input flags
    String allowedChars = "";
    if (includeLetters) allowedChars += letters;
    if (includeNumbers) allowedChars += numbers;
    if (includeSpecialChars) allowedChars += specialChars;

    // Validate that at least one character set is enabled
    if (allowedChars.isEmpty) {
      throw ArgumentError("At least one character set (letters, numbers, or special characters) must be enabled.");
    }

    // Generate random string
    final Random random = Random.secure();
    return String.fromCharCodes(
      List.generate(length, (_) => allowedChars.codeUnitAt(random.nextInt(allowedChars.length))),
    );
  }
}
