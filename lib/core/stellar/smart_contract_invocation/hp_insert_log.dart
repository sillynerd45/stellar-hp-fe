import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HpInsertLog {
  final String fn;

  HpInsertLog({
    required this.fn,
  });

  Future<void> invoke({
    required String logValue,
    required String seed,
  }) async {
    String publicKey = KeyPair.fromSecretSeed(seed).accountId;
    debugPrint('Invoke $fn for $publicKey');

    AccountResponse account = await getIt<StellarNetwork>().stellar.accounts.account(publicKey);

    int year = 2025;
    int month = 3;
    int date = 28;
    int logType = 3;
    String encryptedLogValue = getIt<HashService>().encrypt(plainText: logValue, seed: seed);
    String yearHash = getIt<HashService>().generate(publicKey: publicKey);
    String monthHash = getIt<HashService>().generate(publicKey: publicKey);
    String dateHash = getIt<HashService>().generate(publicKey: publicKey);

    List<XdrSCVal> params = [
      XdrSCVal.forAccountAddress(publicKey),
      XdrSCVal.forU32(year),
      XdrSCVal.forU32(month),
      XdrSCVal.forU32(date),
      XdrSCVal.forU32(logType),
      XdrSCVal.forString(encryptedLogValue),
      XdrSCVal.forString(yearHash),
      XdrSCVal.forString(monthHash),
      XdrSCVal.forString(dateHash),
    ];

    InvokeHostFunctionOperation operation = getIt<SorobanSmartContract>().buildOperation(fn, params);
    Transaction transaction = TransactionBuilder(account).addOperation(operation).build();
    SimulateTransactionRequest simulateRequest = SimulateTransactionRequest(transaction);
    SimulateTransactionResponse simulateResponse =
        await getIt<SorobanSmartContract>().soroban.simulateTransaction(simulateRequest);
    if (simulateResponse.resultError?.contains('Error') ?? false) {
      HpError error =
          getIt<ContractTxHandler>().parseError(errorMessage: simulateResponse.jsonResponse['result']['error']);
      if (kDebugMode) {
        debugPrint('preflight: $error');
        debugPrint('---------------------------------------------------------');
      }
      return;
    }

    List<SimulateTransactionResult> preflight = simulateResponse.results ?? [];
    if (preflight.isEmpty && preflight.first.resultValue == null) {
      if (kDebugMode) {
        debugPrint('preflight: empty result');
        debugPrint('---------------------------------------------------------');
      }
      return;
    }

    debugPrint('preflight type: ${preflight.first.resultValue!.discriminant.value}');
    int preflightResult = preflight.first.resultValue!.u32!.uint32;
    debugPrint('preflight result: $preflightResult');

    GetTransactionResponse? getTxResponse =
        await getIt<ContractTxHandler>().signAndSubmit(account, transaction, simulateResponse, publicKey);
    if (getTxResponse == null || getTxResponse.status != GetTransactionResponse.STATUS_SUCCESS) return;
    int result = getTxResponse.getResultValue()!.u32!.uint32;
    debugPrint('getTxResponse result: $result');
    debugPrint('---------------------------------------------------------');
  }
}
