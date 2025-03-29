import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HpInsertLog {
  final String fn;

  HpInsertLog({
    required this.fn,
  });

  Future<bool> invoke({
    required String publicKey,
    required DateTime chosenLogTime,
    required DailyHealthLogs dailyData,
  }) async {
    debugPrint('Invoke $fn for $publicKey');

    AccountResponse account = await getIt<StellarNetwork>().stellar.accounts.account(publicKey);

    // encrypt log value
    String plainLogValue = jsonEncode(dailyData.toJson());
    String encryptedLogValue =
        getIt<HashService>().encrypt(plainText: plainLogValue, seed: getIt<UserIdService>().getSeed());

    int year = chosenLogTime.year;
    int month = chosenLogTime.month;
    int date = chosenLogTime.day;
    String yearHash = getIt<HashService>().generate(publicKey: publicKey);
    String monthHash = getIt<HashService>().generate(publicKey: publicKey);
    String dateHash = getIt<HashService>().generate(publicKey: publicKey);

    List<XdrSCVal> params = [
      XdrSCVal.forAccountAddress(publicKey),
      XdrSCVal.forU32(year),
      XdrSCVal.forU32(month),
      XdrSCVal.forU32(date),
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

    debugPrint('preflight type: ${preflight.first.resultValue!.discriminant.value}');
    int preflightResult = preflight.first.resultValue!.u32!.uint32;
    debugPrint('preflight result: $preflightResult');

    GetTransactionResponse? getTxResponse =
        await getIt<ContractTxHandler>().signAndSubmit(account, transaction, simulateResponse, publicKey);
    if (getTxResponse == null || getTxResponse.status != GetTransactionResponse.STATUS_SUCCESS) return false;
    int result = getTxResponse.getResultValue()!.u32!.uint32;
    debugPrint('getTxResponse result: $result');
    debugPrint('---------------------------------------------------------');

    return true;
  }
}
