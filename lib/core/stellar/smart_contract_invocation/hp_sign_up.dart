import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HpSignUp {
  final String fn;

  HpSignUp({
    required this.fn,
  });

  Future<void> invoke({
    required String publicKey,
  }) async {
    debugPrint('Invoke $fn for $publicKey');

    AccountResponse account = await getIt<StellarNetwork>().stellar.accounts.account(publicKey);

    String userName = "starlink";
    int sex = 1;
    int age = 27;
    int ageUnit = 2;
    int weight = 76;
    int weightUnit = 0;
    int accountType = 0;
    String logHash = getIt<HashService>().generate(publicKey: publicKey);

    List<XdrSCVal> params = [
      XdrSCVal.forAccountAddress(publicKey),
      XdrSCVal.forString(userName),
      XdrSCVal.forU32(sex),
      XdrSCVal.forU32(age),
      XdrSCVal.forU32(ageUnit),
      XdrSCVal.forU32(weight),
      XdrSCVal.forU32(weightUnit),
      XdrSCVal.forU32(accountType),
      XdrSCVal.forString(logHash),
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
