import 'package:stellar_hp_fe/core/core.dart';

class DailyHealthLogs {
  DailyHealthLogs({
    required this.bodyTemperature,
    required this.bloodPressure,
    required this.symptom,
    required this.medicine,
    required this.encryptedData,
  });

  final List<BodyTemperature> bodyTemperature;
  final List<BloodPressure> bloodPressure;
  final List<Symptom> symptom;
  final List<Medicine> medicine;
  final String? encryptedData;

  DailyHealthLogs copyWith({
    List<BodyTemperature>? bodyTemperature,
    List<BloodPressure>? bloodPressure,
    List<Symptom>? symptom,
    List<Medicine>? medicine,
    String? encryptedData,
  }) {
    return DailyHealthLogs(
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      symptom: symptom ?? this.symptom,
      medicine: medicine ?? this.medicine,
      encryptedData: encryptedData ?? this.encryptedData,
    );
  }

  factory DailyHealthLogs.fromJson(Map<dynamic, dynamic> json) {
    return DailyHealthLogs(
      bodyTemperature: json["bodyTemperature"] == null
          ? []
          : List<BodyTemperature>.from(
          json["bodyTemperature"]!.map((x) => BodyTemperature.fromJson(x))),
      bloodPressure: json["bloodPressure"] == null
          ? []
          : List<BloodPressure>.from(json["bloodPressure"]!.map((x) => BloodPressure.fromJson(x))),
      symptom: json["symptom"] == null
          ? []
          : List<Symptom>.from(json["symptom"]!.map((x) => Symptom.fromJson(x))),
      medicine: json["medicine"] == null
          ? []
          : List<Medicine>.from(json["medicine"]!.map((x) => Medicine.fromJson(x))),
      encryptedData: json["encryptedData"],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJsonResult = {};

    if (bodyTemperature.isNotEmpty) {
      toJsonResult
          .addEntries({"bodyTemperature": bodyTemperature.map((x) => x.toJson()).toList()}.entries);
    }
    if (bloodPressure.isNotEmpty) {
      toJsonResult
          .addEntries({"bloodPressure": bloodPressure.map((x) => x.toJson()).toList()}.entries);
    }
    if (symptom.isNotEmpty) {
      toJsonResult.addEntries({"symptom": symptom.map((x) => x.toJson()).toList()}.entries);
    }
    if (medicine.isNotEmpty) {
      toJsonResult.addEntries({"medicine": medicine.map((x) => x.toJson()).toList()}.entries);
    }
    if (encryptedData != null) toJsonResult.addEntries({"encryptedData": encryptedData}.entries);

    return toJsonResult;
  }
}
