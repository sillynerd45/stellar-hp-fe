import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import 'package:stellar_hp_fe/core/core.dart';

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

  String removePemHeaders(String publicPem) {
    return publicPem
        .replaceAll('-----BEGIN RSA PUBLIC KEY-----', '')
        .replaceAll('-----END RSA PUBLIC KEY-----', '')
        .replaceAll(RegExp(r'\s+'), '');
  }

  String addPemHeaders(String headerLessPublicPem) {
    final formattedBody = headerLessPublicPem.replaceAllMapped(
      RegExp(r'.{1,64}', dotAll: true),
      (match) => '${match.group(0)}\n',
    );

    return '''
    -----BEGIN RSA PUBLIC KEY-----
    $formattedBody
    -----END RSA PUBLIC KEY-----
    ''';
  }

  String encryptRSA({
    required String plainText,
    required String publicKeyPem,
  }) {
    Encrypter encrypterRSA = Encrypter(RSA(publicKey: CryptoUtils.rsaPublicKeyFromPem(publicKeyPem)));

    Key key = Key.fromSecureRandom(32);
    IV iv = IV.fromSecureRandom(16);
    Encrypted encryptedKey = encrypterRSA.encryptBytes(key.bytes);
    Encrypted encryptedIV = encrypterRSA.encryptBytes(iv.bytes);
    Encrypter aesEncrypter = Encrypter(AES(key, mode: AESMode.cbc));
    Encrypted encryptedData = aesEncrypter.encrypt(plainText, iv: iv);

    Map<String, String> payload = {
      'a': encryptedKey.base64,
      'b': encryptedIV.base64,
      'c': encryptedData.base64,
    };

    return jsonEncode(payload);
  }

  String decryptRSA({
    required String encryptedText,
    required String privateKeyPem,
  }) {
    Map<String, dynamic> parsed = jsonDecode(encryptedText);

    String encryptedKeyBase64 = parsed['a'];
    String encryptedIVBase64 = parsed['b'];
    String encryptedDataBase64 = parsed['c'];

    Encrypted encryptedKey = Encrypted.fromBase64(encryptedKeyBase64);
    Encrypted encryptedIV = Encrypted.fromBase64(encryptedIVBase64);
    Encrypted encryptedData = Encrypted.fromBase64(encryptedDataBase64);

    Encrypter decrypterRSA = Encrypter(RSA(privateKey: CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem)));
    final aesKeyBytes = decrypterRSA.decryptBytes(encryptedKey);
    final aesIVBytes = decrypterRSA.decryptBytes(encryptedIV);

    Encrypter aesDecrypter = Encrypter(AES(Key(Uint8List.fromList(aesKeyBytes)), mode: AESMode.cbc));
    String decryptedData = aesDecrypter.decrypt(encryptedData, iv: IV(Uint8List.fromList(aesIVBytes)));

    return decryptedData;
  }

  String getPublicKeyPEM(AsymmetricKeyPair keyPair) {
    return CryptoUtils.encodeRSAPublicKeyToPemPkcs1(keyPair.publicKey as RSAPublicKey);
  }

  String getPrivateKeyPEM(AsymmetricKeyPair keyPair) {
    return CryptoUtils.encodeRSAPrivateKeyToPem(keyPair.privateKey as RSAPrivateKey);
  }

  String encodeYearlyHealthLogsRSA(
    Map<String, YearlyHealthLogs> data,
    String publicKeyPem,
  ) {
    final jsonMap = data.map((yearKey, yearlyLogs) {
      return MapEntry(yearKey, yearlyLogs.toJson());
    });
    return encryptRSA(plainText: jsonEncode(jsonMap), publicKeyPem: publicKeyPem);
  }

  Map<String, YearlyHealthLogs> decodeYearlyHealthLogsRSA(
    String encryptedText,
    String privateKeyPem,
  ) {
    String jsonString = decryptRSA(encryptedText: encryptedText, privateKeyPem: privateKeyPem);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return jsonMap.map((yearKey, yearlyLogsJson) {
      return MapEntry(yearKey, YearlyHealthLogs.fromJson(yearlyLogsJson));
    });
  }
}

class EncryptedData {
  final Encrypted encryptedKey;
  final Encrypted encryptedIV;
  final Encrypted encryptedData;

  EncryptedData({
    required this.encryptedKey,
    required this.encryptedIV,
    required this.encryptedData,
  });
}
