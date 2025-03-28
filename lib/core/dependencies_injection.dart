import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init({
    required String rpc,
    required String seed,
    required String contractAddress,
  }) async {
    // Provider
    getIt.registerLazySingleton(() => MainProvider());

    // Service
    getIt.registerLazySingleton(() => HashService());
    getIt.registerLazySingleton(() => DatabaseService());
    getIt.registerLazySingleton(() => SorobanServer(rpc));
    getIt.registerLazySingleton(() => UserIdService(userKeypair: KeyPair.fromSecretSeed(seed)));
    getIt.registerLazySingleton(() => StellarNetwork(stellar: StellarSDK.TESTNET));
    getIt.registerLazySingleton(
      () => SorobanSmartContract(
        soroban: getIt(),
        network: Network.TESTNET,
        contractID: StrKey.decodeContractIdHex(contractAddress),
        contractADDRESS: contractAddress,
      ),
    );

    // Storage
    getIt.registerLazySingletonAsync<SharedPreferences>(() {
      return SharedPreferences.getInstance();
    });

    // Smart Contract Function
    getIt.registerLazySingleton(() => HpSignUp(fn: 'sign_up'));
    getIt.registerLazySingleton(() => HpGetLogHash(fn: 'get_log_hash'));
    getIt.registerLazySingleton(() => HpReadLog(fn: 'read_log'));
    getIt.registerLazySingleton(() => HpInsertLog(fn: 'insert_log'));

    // Smart Contract Component
    getIt.registerLazySingleton(() => ContractTxHandler());
  }
}
