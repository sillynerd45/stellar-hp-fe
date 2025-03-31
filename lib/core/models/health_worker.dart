class HealthWorker {
  HealthWorker({
    required this.name,
    required this.hashId,
  });

  final String? name;
  final String? hashId;

  HealthWorker copyWith({
    String? name,
    String? hashId,
  }) {
    return HealthWorker(
      name: name ?? this.name,
      hashId: hashId ?? this.hashId,
    );
  }

  factory HealthWorker.fromJson(Map<dynamic, dynamic> json) {
    return HealthWorker(
      name: json["name"],
      hashId: json["hashId"],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJsonResult = {};

    if (name != null) toJsonResult.addEntries({"name": name}.entries);
    if (hashId != null) toJsonResult.addEntries({"hashId": hashId}.entries);

    return toJsonResult;
  }
}
