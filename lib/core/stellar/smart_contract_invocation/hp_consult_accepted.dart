import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HpConsultAccepted {
  final String fn;

  HpConsultAccepted({
    required this.fn,
  });

  Future<bool> invoke({
    required String publicKey,
    required String name,
    required String userHash,
    required String doctorHash,
    required String doctorRSA,
    required String dataPeriod,
    required String consultHash,
  }) async {
    debugPrint('Invoke $fn for $publicKey');

    AccountResponse account = await getIt<StellarNetwork>().stellar.accounts.account(publicKey);
    String encodedDoctorRSA = getIt<HashService>().removePemHeaders(doctorRSA);

    List<XdrSCVal> params = [
      XdrSCVal.forAccountAddress(publicKey),
      XdrSCVal.forString(name),
      XdrSCVal.forString(userHash),
      XdrSCVal.forString(doctorHash),
      XdrSCVal.forString(encodedDoctorRSA),
      XdrSCVal.forString(dataPeriod),
      XdrSCVal.forString(consultHash),
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
