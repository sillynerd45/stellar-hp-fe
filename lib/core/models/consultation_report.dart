class ConsultationReport {
  ConsultationReport({
    required this.report,
    required this.period,
    required this.epochTimestamp,
    required this.encryptedData,
  });

  final String? report;
  final String? period;
  final int? epochTimestamp;
  final String? encryptedData;

  ConsultationReport copyWith({
    String? report,
    String? period,
    int? epochTimestamp,
    String? encryptedData,
  }) {
    return ConsultationReport(
      report: report ?? this.report,
      period: period ?? this.period,
      epochTimestamp: epochTimestamp ?? this.epochTimestamp,
      encryptedData: encryptedData ?? this.encryptedData,
    );
  }

  factory ConsultationReport.fromJson(Map<dynamic, dynamic> json) {
    return ConsultationReport(
      report: json["report"],
      period: json["period"],
      epochTimestamp: json["epochTimestamp"],
      encryptedData: json["encryptedData"],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJsonResult = {};

    if (report != null) toJsonResult.addEntries({"report": report}.entries);
    if (period != null) toJsonResult.addEntries({"period": period}.entries);
    if (epochTimestamp != null) toJsonResult.addEntries({"epochTimestamp": epochTimestamp}.entries);
    if (encryptedData != null) toJsonResult.addEntries({"encryptedData": encryptedData}.entries);

    return toJsonResult;
  }
}