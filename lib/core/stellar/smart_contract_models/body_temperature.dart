class BodyTemperature {
  BodyTemperature({
    required this.temperature,
    required this.unit,
    required this.epochTimestamp,
  });

  final double temperature;
  final String unit;
  final int epochTimestamp;

  BodyTemperature copyWith({
    double? temperature,
    String? unit,
    int? epochTimestamp,
  }) {
    return BodyTemperature(
      temperature: temperature ?? this.temperature,
      unit: unit ?? this.unit,
      epochTimestamp: epochTimestamp ?? this.epochTimestamp,
    );
  }

  factory BodyTemperature.fromJson(Map<dynamic, dynamic> json) {
    num temperature = json["temperature"];

    return BodyTemperature(
      temperature: temperature.toDouble(),
      unit: json["unit"],
      epochTimestamp: json["epochTimestamp"],
    );
  }

  Map<String, dynamic> toJson() => {
        "temperature": temperature,
        "unit": unit,
        "epochTimestamp": epochTimestamp,
      };
}
