import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'consult.dart';

class ConsultData extends Consult {
  final String name;
  final String toDoctor;
  final String fromUser;
  final String userRsa;
  final String dataHash;
  @override
  final String consultHash;

  ConsultData({
    required this.name,
    required this.toDoctor,
    required this.fromUser,
    required this.userRsa,
    required this.dataHash,
    required this.consultHash,
  });

  factory ConsultData.parse(XdrSCVal xdrSCVal) {
    String name = '';
    String toDoctor = '';
    String fromUser = '';
    String userRsa = '';
    String dataHash = '';
    String consultHash = '';

    for (XdrSCMapEntry v in xdrSCVal.map!) {
      if (v.key.sym == null) continue;
      if (v.key.sym == 'name') name = v.val.str.toString();
      if (v.key.sym == 'to_doctor') toDoctor = v.val.str.toString();
      if (v.key.sym == 'from_user') fromUser = v.val.str.toString();
      if (v.key.sym == 'user_rsa') userRsa = v.val.str.toString();
      if (v.key.sym == 'data_hash') dataHash = v.val.str.toString();
      if (v.key.sym == 'consult_hash') consultHash = v.val.str.toString();
    }

    return ConsultData(
      name: name,
      toDoctor: toDoctor,
      fromUser: fromUser,
      userRsa: userRsa,
      dataHash: dataHash,
      consultHash: consultHash,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ConsultData &&
            name == other.name &&
            consultHash == other.consultHash &&
            toDoctor == other.toDoctor &&
            fromUser == other.fromUser &&
            userRsa == other.userRsa &&
            dataHash == other.dataHash);
  }

  @override
  int get hashCode => Object.hash(name, consultHash, toDoctor, fromUser, userRsa, dataHash);
}
