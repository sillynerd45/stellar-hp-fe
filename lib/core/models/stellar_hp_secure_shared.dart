import 'package:stellar_hp_fe/core/core.dart';

class HpSecureSharedUser {
  final String doctorHash;
  final String publicRSA;
  final String privateRSA;
  final Map<String, YearlyHealthLogs> logs;
  final String dataPeriod;

  HpSecureSharedUser({
    required this.doctorHash,
    required this.publicRSA,
    required this.privateRSA,
    required this.logs,
    required this.dataPeriod,
  });

  Map<String, dynamic> toJson() => {
        'doctorHash': doctorHash,
        'publicRSA': publicRSA,
        'privateRSA': privateRSA,
        'logs': logs.map((key, value) => MapEntry(key, value.toJson())),
        'dataPeriod': dataPeriod,
      };

  factory HpSecureSharedUser.fromJson(Map<String, dynamic> json) {
    return HpSecureSharedUser(
      doctorHash: json['doctorHash'],
      publicRSA: json['publicRSA'],
      privateRSA: json['privateRSA'],
      logs: Map.from(json['logs']).map(
        (key, value) => MapEntry(key, YearlyHealthLogs.fromJson(value)),
      ),
      dataPeriod: json['dataPeriod'],
    );
  }
}

class HpSecureSharedDoctor {
  final String userHash;
  final String publicRSA;
  final String privateRSA;

  HpSecureSharedDoctor({
    required this.userHash,
    required this.publicRSA,
    required this.privateRSA,
  });

  Map<String, dynamic> toJson() => {
        'userHash': userHash,
        'publicRSA': publicRSA,
        'privateRSA': privateRSA,
      };

  factory HpSecureSharedDoctor.fromJson(Map<String, dynamic> json) {
    return HpSecureSharedDoctor(
      userHash: json['userHash'],
      publicRSA: json['publicRSA'],
      privateRSA: json['privateRSA'],
    );
  }
}
