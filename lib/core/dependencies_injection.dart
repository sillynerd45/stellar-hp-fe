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
    getIt.registerLazySingleton(() => ConsultationProvider());

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
    getIt.registerLazySingleton(() => HpInsertLog(fn: 'insert_log'));
    getIt.registerLazySingleton(() => HpGetProfile(fn: 'get_profile'));
    getIt.registerLazySingleton(() => HpReadAllLog(fn: 'read_all_log'));
    getIt.registerLazySingleton(() => HpGetHealthWorkers(fn: 'get_health_workers'));
    getIt.registerLazySingleton(() => HpConsultRequest(fn: 'consult_request'));
    getIt.registerLazySingleton(() => HpConsultAccepted(fn: 'consult_accepted'));
    getIt.registerLazySingleton(() => HpConsultData(fn: 'consult_data'));
    getIt.registerLazySingleton(() => HpGetSingleLog(fn: 'get_single_log'));
    getIt.registerLazySingleton(() => HpConsultResult(fn: 'consult_result'));

    // Smart Contract Component
    getIt.registerLazySingleton(() => ContractTxHandler());
  }
}
