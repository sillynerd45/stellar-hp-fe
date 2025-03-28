class BloodPressure {
  BloodPressure({
    required this.systolic,
    required this.diastolic,
    required this.epochTimestamp,
  });

  final int systolic;
  final int diastolic;
  final int epochTimestamp;

  BloodPressure copyWith({
    int? systolic,
    int? diastolic,
    int? epochTimestamp,
  }) {
    return BloodPressure(
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      epochTimestamp: epochTimestamp ?? this.epochTimestamp,
    );
  }

  factory BloodPressure.fromJson(Map<dynamic, dynamic> json) {
    return BloodPressure(
      systolic: json["systolic"],
      diastolic: json["diastolic"],
      epochTimestamp: json["epochTimestamp"],
    );
  }

  Map<String, dynamic> toJson() => {
        "systolic": systolic,
        "diastolic": diastolic,
        "epochTimestamp": epochTimestamp,
      };
}
