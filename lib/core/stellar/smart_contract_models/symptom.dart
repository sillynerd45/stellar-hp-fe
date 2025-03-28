class Symptom {
  Symptom({
    required this.note,
    required this.epochTimestamp,
  });

  final String note;
  final int epochTimestamp;

  Symptom copyWith({
    String? note,
    int? epochTimestamp,
  }) {
    return Symptom(
      note: note ?? this.note,
      epochTimestamp: epochTimestamp ?? this.epochTimestamp,
    );
  }

  factory Symptom.fromJson(Map<dynamic, dynamic> json) {
    return Symptom(
      note: json["note"],
      epochTimestamp: json["epochTimestamp"],
    );
  }

  Map<String, dynamic> toJson() => {
        "note": note,
        "epochTimestamp": epochTimestamp,
      };
}
