import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HpReadLog {
  final String fn;

  HpReadLog({
    required this.fn,
  });

  Future<void> invoke({
    required String seed,
  }) async {
    String publicKey = KeyPair.fromSecretSeed(seed).accountId;
    debugPrint('Invoke $fn for $publicKey');

    AccountResponse account = await getIt<StellarNetwork>().stellar.accounts.account(publicKey);

    int year = 2025;
    int month = 3;
    int date = 28;

    List<XdrSCVal> params = [
      XdrSCVal.forAccountAddress(publicKey),
      XdrSCVal.forU32(year),
      XdrSCVal.forU32(month),
      XdrSCVal.forU32(date),
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
    // String preflightResult = preflight.first.resultValue!.str!;
    // debugPrint('preflight result: $preflightResult');
    debugPrint('---------------------------------------------------------');

    for (XdrSCMapEntry m in preflight.first.resultValue!.map!) {
      if (m.key.u32 != null && m.val.vec != null) {
        debugPrint('u32: ${m.key.u32!.uint32}');
        for (XdrSCVal data in m.val.vec!) {
          debugPrint('${data.str}');
          String text = getIt<HashService>().decrypt(encryptedText: data.str!, seed: seed);
          debugPrint(text);
        }
      }

      // if (v.key.sym == null) continue;
      // if (v.key.sym == 'status' && v.val.vec != null) {
      //   status = (v.val.vec?.first.sym ?? '').getStatus();
      // }
      // if (v.key.sym == 'cow_data' && v.val.vec != null) {
      //   for (XdrSCVal data in v.val.vec!) {
      //     CowData cow = await getCowData(data.map!);
      //     cowData.add(cow);
      //   }
      // }
      // if (v.key.sym == 'ownership' && v.val.vec != null) {
      //   for (XdrSCVal data in v.val.vec!) {
      //     ownershipData.add(data.str.toString());
      //   }
      // }
    }

    debugPrint('---------------------------------------------------------');
  }
}
