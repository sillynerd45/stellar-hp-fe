class Medicine {
  Medicine({
    required this.meds,
    required this.epochTimestamp,
  });

  final List<MedicineProperties> meds;
  final int epochTimestamp;

  Medicine copyWith({
    List<MedicineProperties>? meds,
    int? epochTimestamp,
  }) {
    return Medicine(
      meds: meds ?? this.meds,
      epochTimestamp: epochTimestamp ?? this.epochTimestamp,
    );
  }

  factory Medicine.fromJson(Map<dynamic, dynamic> json) {
    return Medicine(
      meds: json["meds"] == null
          ? []
          : List<MedicineProperties>.from(json["meds"]!.map((x) => MedicineProperties.fromJson(x))),
      epochTimestamp: json["epochTimestamp"],
    );
  }

  Map<String, dynamic> toJson() => {
        "meds": meds.map((x) => x.toJson()).toList(),
        "epochTimestamp": epochTimestamp,
      };
}

class MedicineProperties {
  MedicineProperties({
    required this.name,
    required this.quantity,
  });

  final String name;
  final double quantity;

  MedicineProperties copyWith({
    String? name,
    double? quantity,
  }) {
    return MedicineProperties(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }

  factory MedicineProperties.fromJson(Map<dynamic, dynamic> json) {
    num quantity = json["quantity"];
    return MedicineProperties(
      name: json["name"],
      quantity: quantity.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "quantity": quantity,
      };
}
