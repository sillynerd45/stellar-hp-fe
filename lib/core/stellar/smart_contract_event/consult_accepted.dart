import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'consult.dart';

class ConsultAccepted extends Consult {
  final String name;
  final String toUser;
  final String fromDoctor;
  final String doctorRsa;
  final String dataPeriod;
  @override
  final String consultHash;

  ConsultAccepted({
    required this.name,
    required this.toUser,
    required this.fromDoctor,
    required this.doctorRsa,
    required this.dataPeriod,
    required this.consultHash,
  });

  factory ConsultAccepted.parse(XdrSCVal xdrSCVal) {
    String name = '';
    String toUser = '';
    String fromDoctor = '';
    String doctorRsa = '';
    String dataPeriod = '';
    String consultHash = '';

    for (XdrSCMapEntry v in xdrSCVal.map!) {
      if (v.key.sym == null) continue;
      if (v.key.sym == 'name') name = v.val.str.toString();
      if (v.key.sym == 'to_user') toUser = v.val.str.toString();
      if (v.key.sym == 'from_doctor') fromDoctor = v.val.str.toString();
      if (v.key.sym == 'doctor_rsa') doctorRsa = v.val.str.toString();
      if (v.key.sym == 'data_period') dataPeriod = v.val.str.toString();
      if (v.key.sym == 'consult_hash') consultHash = v.val.str.toString();
    }

    return ConsultAccepted(
      name: name,
      toUser: toUser,
      fromDoctor: fromDoctor,
      doctorRsa: doctorRsa,
      dataPeriod:dataPeriod,
      consultHash: consultHash,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ConsultAccepted &&
            name == other.name &&
            consultHash == other.consultHash &&
            toUser == other.toUser &&
            fromDoctor == other.fromDoctor &&
            doctorRsa == other.doctorRsa &&
            dataPeriod == other.dataPeriod);
  }

  @override
  int get hashCode => Object.hash(name, consultHash, toUser, fromDoctor, doctorRsa, dataPeriod);
}
