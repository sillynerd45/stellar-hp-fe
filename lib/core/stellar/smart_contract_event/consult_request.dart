import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'consult.dart';

class ConsultRequest extends Consult {
  final String toDoctor;
  final String fromUser;
  final String name;
  final String dataPeriod;
  @override
  final String consultHash;

  ConsultRequest({
    required this.toDoctor,
    required this.fromUser,
    required this.name,
    required this.dataPeriod,
    required this.consultHash,
  });

  factory ConsultRequest.parse(XdrSCVal xdrSCVal) {
    String toDoctor = '';
    String fromUser = '';
    String name = '';
    String dataPeriod = '';
    String consultHash = '';

    for (XdrSCMapEntry v in xdrSCVal.map!) {
      if (v.key.sym == null) continue;
      if (v.key.sym == 'to_doctor') toDoctor = v.val.str.toString();
      if (v.key.sym == 'from_user') fromUser = v.val.str.toString();
      if (v.key.sym == 'name') name = v.val.str.toString();
      if (v.key.sym == 'data_period') dataPeriod = v.val.str.toString();
      if (v.key.sym == 'consult_hash') consultHash = v.val.str.toString();
    }

    return ConsultRequest(
      toDoctor: toDoctor,
      fromUser: fromUser,
      name: name,
      dataPeriod: dataPeriod,
      consultHash: consultHash,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ConsultRequest &&
            consultHash == other.consultHash &&
            toDoctor == other.toDoctor &&
            fromUser == other.fromUser &&
            name == other.name &&
            dataPeriod == other.dataPeriod);
  }

  @override
  int get hashCode => Object.hash(consultHash, toDoctor, fromUser, name, dataPeriod);
}
