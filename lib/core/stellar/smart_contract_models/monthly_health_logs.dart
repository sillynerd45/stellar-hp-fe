import 'package:stellar_hp_fe/core/core.dart';

class MonthlyHealthLogs {
  MonthlyHealthLogs({
    required this.d1,
    required this.d2,
    required this.d3,
    required this.d4,
    required this.d5,
    required this.d6,
    required this.d7,
    required this.d8,
    required this.d9,
    required this.d10,
    required this.d11,
    required this.d12,
    required this.d13,
    required this.d14,
    required this.d15,
    required this.d16,
    required this.d17,
    required this.d18,
    required this.d19,
    required this.d20,
    required this.d21,
    required this.d22,
    required this.d23,
    required this.d24,
    required this.d25,
    required this.d26,
    required this.d27,
    required this.d28,
    required this.d29,
    required this.d30,
    required this.d31,
  });

  final DailyHealthLogs? d1;
  final DailyHealthLogs? d2;
  final DailyHealthLogs? d3;
  final DailyHealthLogs? d4;
  final DailyHealthLogs? d5;
  final DailyHealthLogs? d6;
  final DailyHealthLogs? d7;
  final DailyHealthLogs? d8;
  final DailyHealthLogs? d9;
  final DailyHealthLogs? d10;
  final DailyHealthLogs? d11;
  final DailyHealthLogs? d12;
  final DailyHealthLogs? d13;
  final DailyHealthLogs? d14;
  final DailyHealthLogs? d15;
  final DailyHealthLogs? d16;
  final DailyHealthLogs? d17;
  final DailyHealthLogs? d18;
  final DailyHealthLogs? d19;
  final DailyHealthLogs? d20;
  final DailyHealthLogs? d21;
  final DailyHealthLogs? d22;
  final DailyHealthLogs? d23;
  final DailyHealthLogs? d24;
  final DailyHealthLogs? d25;
  final DailyHealthLogs? d26;
  final DailyHealthLogs? d27;
  final DailyHealthLogs? d28;
  final DailyHealthLogs? d29;
  final DailyHealthLogs? d30;
  final DailyHealthLogs? d31;

  MonthlyHealthLogs copyWith({
    DailyHealthLogs? d1,
    DailyHealthLogs? d2,
    DailyHealthLogs? d3,
    DailyHealthLogs? d4,
    DailyHealthLogs? d5,
    DailyHealthLogs? d6,
    DailyHealthLogs? d7,
    DailyHealthLogs? d8,
    DailyHealthLogs? d9,
    DailyHealthLogs? d10,
    DailyHealthLogs? d11,
    DailyHealthLogs? d12,
    DailyHealthLogs? d13,
    DailyHealthLogs? d14,
    DailyHealthLogs? d15,
    DailyHealthLogs? d16,
    DailyHealthLogs? d17,
    DailyHealthLogs? d18,
    DailyHealthLogs? d19,
    DailyHealthLogs? d20,
    DailyHealthLogs? d21,
    DailyHealthLogs? d22,
    DailyHealthLogs? d23,
    DailyHealthLogs? d24,
    DailyHealthLogs? d25,
    DailyHealthLogs? d26,
    DailyHealthLogs? d27,
    DailyHealthLogs? d28,
    DailyHealthLogs? d29,
    DailyHealthLogs? d30,
    DailyHealthLogs? d31,
  }) {
    return MonthlyHealthLogs(
      d1: d1 ?? this.d1,
      d2: d2 ?? this.d2,
      d3: d3 ?? this.d3,
      d4: d4 ?? this.d4,
      d5: d5 ?? this.d5,
      d6: d6 ?? this.d6,
      d7: d7 ?? this.d7,
      d8: d8 ?? this.d8,
      d9: d9 ?? this.d9,
      d10: d10 ?? this.d10,
      d11: d11 ?? this.d11,
      d12: d12 ?? this.d12,
      d13: d13 ?? this.d13,
      d14: d14 ?? this.d14,
      d15: d15 ?? this.d15,
      d16: d16 ?? this.d16,
      d17: d17 ?? this.d17,
      d18: d18 ?? this.d18,
      d19: d19 ?? this.d19,
      d20: d20 ?? this.d20,
      d21: d21 ?? this.d21,
      d22: d22 ?? this.d22,
      d23: d23 ?? this.d23,
      d24: d24 ?? this.d24,
      d25: d25 ?? this.d25,
      d26: d26 ?? this.d26,
      d27: d27 ?? this.d27,
      d28: d28 ?? this.d28,
      d29: d29 ?? this.d29,
      d30: d30 ?? this.d30,
      d31: d31 ?? this.d31,
    );
  }

  factory MonthlyHealthLogs.fromJson(Map<dynamic, dynamic> json) {
    return MonthlyHealthLogs(
      d1: json["01"] == null ? null : DailyHealthLogs.fromJson(json["01"]),
      d2: json["02"] == null ? null : DailyHealthLogs.fromJson(json["02"]),
      d3: json["03"] == null ? null : DailyHealthLogs.fromJson(json["03"]),
      d4: json["04"] == null ? null : DailyHealthLogs.fromJson(json["04"]),
      d5: json["05"] == null ? null : DailyHealthLogs.fromJson(json["05"]),
      d6: json["06"] == null ? null : DailyHealthLogs.fromJson(json["06"]),
      d7: json["07"] == null ? null : DailyHealthLogs.fromJson(json["07"]),
      d8: json["08"] == null ? null : DailyHealthLogs.fromJson(json["08"]),
      d9: json["09"] == null ? null : DailyHealthLogs.fromJson(json["09"]),
      d10: json["10"] == null ? null : DailyHealthLogs.fromJson(json["10"]),
      d11: json["11"] == null ? null : DailyHealthLogs.fromJson(json["11"]),
      d12: json["12"] == null ? null : DailyHealthLogs.fromJson(json["12"]),
      d13: json["13"] == null ? null : DailyHealthLogs.fromJson(json["13"]),
      d14: json["14"] == null ? null : DailyHealthLogs.fromJson(json["14"]),
      d15: json["15"] == null ? null : DailyHealthLogs.fromJson(json["15"]),
      d16: json["16"] == null ? null : DailyHealthLogs.fromJson(json["16"]),
      d17: json["17"] == null ? null : DailyHealthLogs.fromJson(json["17"]),
      d18: json["18"] == null ? null : DailyHealthLogs.fromJson(json["18"]),
      d19: json["19"] == null ? null : DailyHealthLogs.fromJson(json["19"]),
      d20: json["20"] == null ? null : DailyHealthLogs.fromJson(json["20"]),
      d21: json["21"] == null ? null : DailyHealthLogs.fromJson(json["21"]),
      d22: json["22"] == null ? null : DailyHealthLogs.fromJson(json["22"]),
      d23: json["23"] == null ? null : DailyHealthLogs.fromJson(json["23"]),
      d24: json["24"] == null ? null : DailyHealthLogs.fromJson(json["24"]),
      d25: json["25"] == null ? null : DailyHealthLogs.fromJson(json["25"]),
      d26: json["26"] == null ? null : DailyHealthLogs.fromJson(json["26"]),
      d27: json["27"] == null ? null : DailyHealthLogs.fromJson(json["27"]),
      d28: json["28"] == null ? null : DailyHealthLogs.fromJson(json["28"]),
      d29: json["29"] == null ? null : DailyHealthLogs.fromJson(json["29"]),
      d30: json["30"] == null ? null : DailyHealthLogs.fromJson(json["30"]),
      d31: json["31"] == null ? null : DailyHealthLogs.fromJson(json["31"]),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJsonResult = {};

    if (d1 != null) toJsonResult.addEntries({"01": d1?.toJson()}.entries);
    if (d2 != null) toJsonResult.addEntries({"02": d2?.toJson()}.entries);
    if (d3 != null) toJsonResult.addEntries({"03": d3?.toJson()}.entries);
    if (d4 != null) toJsonResult.addEntries({"04": d4?.toJson()}.entries);
    if (d5 != null) toJsonResult.addEntries({"05": d5?.toJson()}.entries);
    if (d6 != null) toJsonResult.addEntries({"06": d6?.toJson()}.entries);
    if (d7 != null) toJsonResult.addEntries({"07": d7?.toJson()}.entries);
    if (d8 != null) toJsonResult.addEntries({"08": d8?.toJson()}.entries);
    if (d9 != null) toJsonResult.addEntries({"09": d9?.toJson()}.entries);
    if (d10 != null) toJsonResult.addEntries({"10": d10?.toJson()}.entries);
    if (d11 != null) toJsonResult.addEntries({"11": d11?.toJson()}.entries);
    if (d12 != null) toJsonResult.addEntries({"12": d12?.toJson()}.entries);
    if (d13 != null) toJsonResult.addEntries({"13": d13?.toJson()}.entries);
    if (d14 != null) toJsonResult.addEntries({"14": d14?.toJson()}.entries);
    if (d15 != null) toJsonResult.addEntries({"15": d15?.toJson()}.entries);
    if (d16 != null) toJsonResult.addEntries({"16": d16?.toJson()}.entries);
    if (d17 != null) toJsonResult.addEntries({"17": d17?.toJson()}.entries);
    if (d18 != null) toJsonResult.addEntries({"18": d18?.toJson()}.entries);
    if (d19 != null) toJsonResult.addEntries({"19": d19?.toJson()}.entries);
    if (d20 != null) toJsonResult.addEntries({"20": d20?.toJson()}.entries);
    if (d21 != null) toJsonResult.addEntries({"21": d21?.toJson()}.entries);
    if (d22 != null) toJsonResult.addEntries({"22": d22?.toJson()}.entries);
    if (d23 != null) toJsonResult.addEntries({"23": d23?.toJson()}.entries);
    if (d24 != null) toJsonResult.addEntries({"24": d24?.toJson()}.entries);
    if (d25 != null) toJsonResult.addEntries({"25": d25?.toJson()}.entries);
    if (d26 != null) toJsonResult.addEntries({"26": d26?.toJson()}.entries);
    if (d27 != null) toJsonResult.addEntries({"27": d27?.toJson()}.entries);
    if (d28 != null) toJsonResult.addEntries({"28": d28?.toJson()}.entries);
    if (d29 != null) toJsonResult.addEntries({"29": d29?.toJson()}.entries);
    if (d30 != null) toJsonResult.addEntries({"30": d30?.toJson()}.entries);
    if (d31 != null) toJsonResult.addEntries({"31": d31?.toJson()}.entries);

    return toJsonResult;
  }
}
