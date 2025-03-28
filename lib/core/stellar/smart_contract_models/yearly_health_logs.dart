import 'package:stellar_hp_fe/core/core.dart';

class YearlyHealthLogs {
  YearlyHealthLogs({
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
  });

  final MonthlyHealthLogs? january;
  final MonthlyHealthLogs? february;
  final MonthlyHealthLogs? march;
  final MonthlyHealthLogs? april;
  final MonthlyHealthLogs? may;
  final MonthlyHealthLogs? june;
  final MonthlyHealthLogs? july;
  final MonthlyHealthLogs? august;
  final MonthlyHealthLogs? september;
  final MonthlyHealthLogs? october;
  final MonthlyHealthLogs? november;
  final MonthlyHealthLogs? december;

  YearlyHealthLogs copyWith({
    MonthlyHealthLogs? january,
    MonthlyHealthLogs? february,
    MonthlyHealthLogs? march,
    MonthlyHealthLogs? april,
    MonthlyHealthLogs? may,
    MonthlyHealthLogs? june,
    MonthlyHealthLogs? july,
    MonthlyHealthLogs? august,
    MonthlyHealthLogs? september,
    MonthlyHealthLogs? october,
    MonthlyHealthLogs? november,
    MonthlyHealthLogs? december,
  }) {
    return YearlyHealthLogs(
      january: january ?? this.january,
      february: february ?? this.february,
      march: march ?? this.march,
      april: april ?? this.april,
      may: may ?? this.may,
      june: june ?? this.june,
      july: july ?? this.july,
      august: august ?? this.august,
      september: september ?? this.september,
      october: october ?? this.october,
      november: november ?? this.november,
      december: december ?? this.december,
    );
  }

  factory YearlyHealthLogs.fromJson(Map<dynamic, dynamic> json) {
    return YearlyHealthLogs(
      january: json["january"] == null ? null : MonthlyHealthLogs.fromJson(json["january"]),
      february: json["february"] == null ? null : MonthlyHealthLogs.fromJson(json["february"]),
      march: json["march"] == null ? null : MonthlyHealthLogs.fromJson(json["march"]),
      april: json["april"] == null ? null : MonthlyHealthLogs.fromJson(json["april"]),
      may: json["may"] == null ? null : MonthlyHealthLogs.fromJson(json["may"]),
      june: json["june"] == null ? null : MonthlyHealthLogs.fromJson(json["june"]),
      july: json["july"] == null ? null : MonthlyHealthLogs.fromJson(json["july"]),
      august: json["august"] == null ? null : MonthlyHealthLogs.fromJson(json["august"]),
      september: json["september"] == null ? null : MonthlyHealthLogs.fromJson(json["september"]),
      october: json["october"] == null ? null : MonthlyHealthLogs.fromJson(json["october"]),
      november: json["november"] == null ? null : MonthlyHealthLogs.fromJson(json["november"]),
      december: json["december"] == null ? null : MonthlyHealthLogs.fromJson(json["december"]),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJsonResult = {};

    if (january != null) toJsonResult.addEntries({"january": january?.toJson()}.entries);
    if (february != null) toJsonResult.addEntries({"february": february?.toJson()}.entries);
    if (march != null) toJsonResult.addEntries({"march": march?.toJson()}.entries);
    if (april != null) toJsonResult.addEntries({"april": april?.toJson()}.entries);
    if (may != null) toJsonResult.addEntries({"may": may?.toJson()}.entries);
    if (june != null) toJsonResult.addEntries({"june": june?.toJson()}.entries);
    if (july != null) toJsonResult.addEntries({"july": july?.toJson()}.entries);
    if (august != null) toJsonResult.addEntries({"august": august?.toJson()}.entries);
    if (september != null) toJsonResult.addEntries({"september": september?.toJson()}.entries);
    if (october != null) toJsonResult.addEntries({"october": october?.toJson()}.entries);
    if (november != null) toJsonResult.addEntries({"november": november?.toJson()}.entries);
    if (december != null) toJsonResult.addEntries({"december": december?.toJson()}.entries);

    return toJsonResult;
  }
}
