import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

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

  String encrypt({
    required String plainText,
    required String seed,
  }) {
    // Load the secret key
    Key key = Key.fromUtf8(seed.substring(12, 44));

    // Generate a random IV
    IV iv = IV.fromSecureRandom(16);

    // Encrypt
    Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    Encrypted encrypted = encrypter.encrypt(plainText, iv: iv);

    // Combine IV and ciphertext for decryption
    Uint8List combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
    String result = base64.encode(combined);
    return result;
  }

  String decrypt({
    required String encryptedText,
    required String seed,
  }) {
    // Load the secret key
    Key key = Key.fromUtf8(seed.substring(12, 44));

    // Extract IV and ciphertext
    Uint8List combined = base64.decode(encryptedText);
    IV iv = IV(Uint8List.fromList(combined.sublist(0, 16)));
    Encrypted cipherText = Encrypted(Uint8List.fromList(combined.sublist(16)));

    // Decrypt
    Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    String result = encrypter.decrypt(cipherText, iv: iv);
    return result;
  }
}
