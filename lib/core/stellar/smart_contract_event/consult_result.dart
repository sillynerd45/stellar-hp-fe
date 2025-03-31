import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'consult.dart';

class ConsultResult extends Consult {
  final String name;
  final String toUser;
  final String fromDoctor;
  final String resultHash;

  @override
  final String consultHash;

  ConsultResult({
    required this.name,
    required this.toUser,
    required this.fromDoctor,
    required this.resultHash,
    required this.consultHash,
  });

  factory ConsultResult.parse(XdrSCVal xdrSCVal) {
    String name = '';
    String toUser = '';
    String fromDoctor = '';
    String resultHash = '';
    String consultHash = '';

    for (XdrSCMapEntry v in xdrSCVal.map!) {
      if (v.key.sym == null) continue;
      if (v.key.sym == 'name') name = v.val.str.toString();
      if (v.key.sym == 'to_user') toUser = v.val.str.toString();
      if (v.key.sym == 'from_doctor') fromDoctor = v.val.str.toString();
      if (v.key.sym == 'result_hash') resultHash = v.val.str.toString();
      if (v.key.sym == 'consult_hash') consultHash = v.val.str.toString();
    }

    return ConsultResult(
      name: name,
      toUser: toUser,
      fromDoctor: fromDoctor,
      resultHash: resultHash,
      consultHash: consultHash,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ConsultResult &&
            name == other.name &&
            consultHash == other.consultHash &&
            toUser == other.toUser &&
            fromDoctor == other.fromDoctor &&
            resultHash == other.resultHash);
  }

  @override
  int get hashCode => Object.hash(name, consultHash, toUser, fromDoctor, resultHash);
}
