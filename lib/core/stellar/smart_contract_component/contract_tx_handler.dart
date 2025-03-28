import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class ContractTxHandler {
  HpError parseError({
    required String errorMessage,
  }) {
    if (errorMessage.contains('Error(Contract, #1)')) {
      return HpError.userExist;
    }

    if (errorMessage.contains('Error(Contract, #2)')) {
      return HpError.userNotExist;
    }

    if (errorMessage.contains('Error(Contract, #3)')) {
      return HpError.dataNotExist;
    }

    return HpError.unknown;
  }

  int responseCheck(SendTransactionResponse sendTxResponse) {
    if (sendTxResponse.error != null) {
      if (kDebugMode) {
        debugPrint('ContractTxHandler responseCheck error: ${sendTxResponse.error?.message}');
      }
      return 1;
    }

    if (sendTxResponse.hash == null) {
      if (kDebugMode) {
        debugPrint('ContractTxHandler responseCheck error: hash is null');
      }
      return 2;
    }

    if (sendTxResponse.status == SendTransactionResponse.STATUS_ERROR ||
        sendTxResponse.status == SendTransactionResponse.STATUS_DUPLICATE ||
        sendTxResponse.status == SendTransactionResponse.STATUS_TRY_AGAIN_LATER) {
      if (kDebugMode) {
        debugPrint(
            'ContractTxHandler responseCheck error:\nStatus: ${sendTxResponse.status}\nXDR: ${sendTxResponse.errorResultXdr}');
      }
      return 3;
    }

    return 0;
  }

  Future<GetTransactionResponse?> polling(String transactionId) async {
    GetTransactionResponse? transactionResponse;
    String status = GetTransactionResponse.STATUS_NOT_FOUND;

    while (status == GetTransactionResponse.STATUS_NOT_FOUND) {
      transactionResponse = await getIt<SorobanSmartContract>().soroban.getTransaction(transactionId);
      if (transactionResponse.error != null) {
        if (kDebugMode) {
          debugPrint('ContractTxHandler polling error: ${transactionResponse.error?.message}');
        }
        transactionResponse = null;
        break;
      }

      if (transactionResponse.status != null) {
        status = transactionResponse.status!;
      }

      bool isFailedAndXdrNull = status == GetTransactionResponse.STATUS_FAILED && transactionResponse.resultXdr == null;
      bool isSuccessAndXdrNull =
          status == GetTransactionResponse.STATUS_SUCCESS && transactionResponse.resultXdr == null;
      if (isFailedAndXdrNull || isSuccessAndXdrNull) {
        if (kDebugMode) {
          debugPrint('ContractTxHandler polling error: resultXdr is null');
        }
        transactionResponse = null;
        break;
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    return transactionResponse;
  }

  Future<GetTransactionResponse?> signAndSubmit(
    AccountResponse account,
    Transaction transaction,
    SimulateTransactionResponse simulateResponse,
    String publicKey,
  ) async {
    int resourceFee = appDefaultTxFee;
    int? minResourceFee = simulateResponse.restorePreamble?.minResourceFee;
    if (minResourceFee != null) resourceFee = minResourceFee * 2;

    if (simulateResponse.restorePreamble != null) {
      // restore footprint
      account = await getIt<StellarNetwork>().stellar.accounts.account(account.accountId);
      RestoreFootprintOperation restoreOp = RestoreFootprintOperationBuilder().build();
      transaction = TransactionBuilder(account).addOperation(restoreOp).build();
      transaction.sorobanTransactionData = simulateResponse.restorePreamble?.transactionData;
      transaction.addResourceFee(resourceFee);
    } else {
      // normal
      transaction.sorobanTransactionData = simulateResponse.transactionData;
      transaction.addResourceFee(resourceFee);
      transaction.setSorobanAuth(simulateResponse.sorobanAuth);
    }

    transaction.sign(getIt<UserIdService>().userKeypair, getIt<SorobanSmartContract>().network);

    SendTransactionResponse sendTxResponse = await getIt<SorobanSmartContract>().soroban.sendTransaction(transaction);
    int errorCheck = responseCheck(sendTxResponse);
    if (errorCheck != 0) return null;

    return await polling(sendTxResponse.hash!);
  }
}
