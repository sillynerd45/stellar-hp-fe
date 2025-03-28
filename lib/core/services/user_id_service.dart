import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

class UserIdService {
  late KeyPair userKeypair;

  UserIdService({
    required this.userKeypair,
  });

  void saveNewKeypair( KeyPair newKeypair) => userKeypair = newKeypair;

  String getPublicKey() => userKeypair.accountId;

  String getSeed() => userKeypair.secretSeed;
}