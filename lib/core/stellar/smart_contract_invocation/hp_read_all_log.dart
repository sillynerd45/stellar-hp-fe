import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HpReadAllLog {
  final String fn;

  HpReadAllLog({
    required this.fn,
  });

  Future<List<DailyHealthLogs>> invoke({
    required String publicKey,
  }) async {
    debugPrint('Invoke $fn for $publicKey');

    AccountResponse account = await getIt<StellarNetwork>().stellar.accounts.account(publicKey);

    List<XdrSCVal> params = [
      XdrSCVal.forAccountAddress(publicKey),
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
      return [];
    }

    List<SimulateTransactionResult> preflight = simulateResponse.results ?? [];
    if (preflight.isEmpty && preflight.first.resultValue == null) {
      if (kDebugMode) {
        debugPrint('preflight: empty result');
        debugPrint('---------------------------------------------------------');
      }
      return [];
    }

    List<String> preflightResult = [];
    List<DailyHealthLogs> logsData = [];
    for (XdrSCVal data in preflight.first.resultValue!.vec!) {
      preflightResult.add(data.str!);

      String jsonEncodedPlainData =
          getIt<HashService>().decrypt(encryptedText: data.str!, seed: getIt<UserIdService>().getSeed());
      logsData.add(DailyHealthLogs.fromJson(jsonDecode(jsonEncodedPlainData)));
    }

    return logsData;
  }
}
