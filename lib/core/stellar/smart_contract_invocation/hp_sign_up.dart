import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HpSignUp {
  final String fn;

  HpSignUp({
    required this.fn,
  });

  Future<bool> invoke({
    required String publicKey,
    required UserProfile userProfile,
  }) async {
    debugPrint('Invoke $fn for $publicKey');

    AccountResponse account = await getIt<StellarNetwork>().stellar.accounts.account(publicKey);

    // health worker name
    String healthWorkerName = '';
    if (userProfile.accountType == AccountType.healthWorker) {
      healthWorkerName = userProfile.name ?? '---';
    }

    // encrypt profile
    String plainProfileText = jsonEncode(userProfile.toJson());
    String encryptedProfileText =
        getIt<HashService>().encrypt(plainText: plainProfileText, seed: getIt<UserIdService>().getSeed());

    List<XdrSCVal> params = [
      XdrSCVal.forAccountAddress(publicKey),
      XdrSCVal.forString(encryptedProfileText),
      XdrSCVal.forU32(userProfile.accountType!.typeId),
      XdrSCVal.forString(userProfile.logHash!),
      XdrSCVal.forString(healthWorkerName),
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
      return false;
    }

    List<SimulateTransactionResult> preflight = simulateResponse.results ?? [];
    if (preflight.isEmpty && preflight.first.resultValue == null) {
      if (kDebugMode) {
        debugPrint('preflight: empty result');
        debugPrint('---------------------------------------------------------');
      }
      return false;
    }

    int preflightResult = preflight.first.resultValue!.u32!.uint32;

    if (kDebugMode) {
      debugPrint('preflight type: ${preflight.first.resultValue!.discriminant.value}');
      debugPrint('preflight result: $preflightResult');
    }

    GetTransactionResponse? getTxResponse =
        await getIt<ContractTxHandler>().signAndSubmit(account, transaction, simulateResponse, publicKey);
    if (getTxResponse == null || getTxResponse.status != GetTransactionResponse.STATUS_SUCCESS) return false;
    int result = getTxResponse.getResultValue()!.u32!.uint32;

    if (kDebugMode) {
      debugPrint('getTxResponse result: $result');
      debugPrint('---------------------------------------------------------');
    }

    return true;
  }
}
