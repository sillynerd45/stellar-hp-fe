import 'package:stellar_hp_fe/core/core.dart';

class UserProfile {
  UserProfile({
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.encryptedData,
    required this.accountType,
    required this.logHash,
  });

  final String? name;
  final String? gender;
  final Age? age;
  final Weight? weight;
  final String? encryptedData;
  final AccountType? accountType;
  final String? logHash;

  UserProfile copyWith({
    String? name,
    String? gender,
    Age? age,
    Weight? weight,
    String? encryptedData,
    AccountType? accountType,
    String? logHash,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      encryptedData: encryptedData ?? this.encryptedData,
      accountType: accountType ?? this.accountType,
      logHash: logHash ?? this.logHash,
    );
  }

  factory UserProfile.fromJson(Map<dynamic, dynamic> json) {
    return UserProfile(
        name: json["name"],
        gender: json["gender"],
        age: json["age"] == null ? null : Age.fromJson(json["age"]),
        weight: json["weight"] == null ? null : Weight.fromJson(json["weight"]),
        encryptedData: json["encryptedData"],
        accountType: _accountTypeFromString(json['accountType'] as String),
        logHash: json["logHash"]);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJsonResult = {};

    if (name != null) toJsonResult.addEntries({"name": name}.entries);
    if (gender != null) toJsonResult.addEntries({"gender": gender}.entries);
    if (age != null) toJsonResult.addEntries({"age": age?.toJson()}.entries);
    if (weight != null) toJsonResult.addEntries({"weight": weight?.toJson()}.entries);
    if (encryptedData != null) toJsonResult.addEntries({"encryptedData": encryptedData}.entries);
    if (accountType != null) toJsonResult.addEntries({"accountType": accountType!.name}.entries);
    if (logHash != null) toJsonResult.addEntries({"logHash": logHash}.entries);

    return toJsonResult;
  }

  static AccountType _accountTypeFromString(String value) {
    return AccountType.values.firstWhere((e) => e.name == value);
  }
}

class Age {
  Age({
    required this.value,
    required this.unit,
  });

  final int? value;
  final String? unit;

  Age copyWith({
    int? value,
    String? unit,
  }) {
    return Age(
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  factory Age.fromJson(Map<dynamic, dynamic> json) {
    return Age(
      value: json["value"],
      unit: json["unit"],
    );
  }

  Map<String, dynamic> toJson() => {
        "value": value,
        "unit": unit,
      };
}

class Weight {
  Weight({
    required this.value,
    required this.unit,
  });

  final int? value;
  final String? unit;

  Weight copyWith({
    int? value,
    String? unit,
  }) {
    return Weight(
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  factory Weight.fromJson(Map<dynamic, dynamic> json) {
    return Weight(
      value: json["value"],
      unit: json["unit"],
    );
  }

  Map<String, dynamic> toJson() => {
        "value": value,
        "unit": unit,
      };
}

/*
{
	"name": "John",
	"gender": "male",
	"age": {
		"value": "2",
		"unit": "Years"
	},
	"weight": {
		"value": "100",
		"unit": "Kilograms"
	}
}*/
