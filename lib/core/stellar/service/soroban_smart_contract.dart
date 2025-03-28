import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

class SorobanSmartContract {
  final SorobanServer soroban;
  final Network network;
  final String contractID;
  final String contractADDRESS;

  SorobanSmartContract({
    required this.soroban,
    required this.network,
    required this.contractID,
    required this.contractADDRESS,
  });

  InvokeHostFunctionOperation buildOperation(String functionName, List<XdrSCVal> arguments) {
    InvokeContractHostFunction hostFunction = InvokeContractHostFunction(
      contractID,
      functionName,
      arguments: arguments,
    );
    return InvokeHostFuncOpBuilder(hostFunction).build();
  }
}
