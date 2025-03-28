class StellarHpDate {
  StellarHpDate({
    required this.day,
    required this.date,
    required this.month,
    required this.title,
    required this.dateTime,
    required this.unixTime,
  });

  final String? day;
  final String? date;
  final String? month;
  final String? title;
  final DateTime? dateTime;
  final int? unixTime;

  StellarHpDate copyWith({
    String? day,
    String? date,
    String? month,
    String? title,
    DateTime? dateTime,
    int? unixTime,
  }) {
    return StellarHpDate(
      day: day ?? this.day,
      date: date ?? this.date,
      month: month ?? this.month,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      unixTime: unixTime ?? this.unixTime,
    );
  }

  factory StellarHpDate.fromJson(Map<String, dynamic> json) {
    return StellarHpDate(
      day: json["day"],
      date: json["date"],
      month: json["month"],
      title: json["title"],
      dateTime: json["dateTime"],
      unixTime: json["unixTime"],
    );
  }

  Map<String, dynamic> toJson() => {
    "day": day,
    "date": date,
    "month": month,
    "title": title,
    "dateTime": dateTime,
    "unixTime": unixTime,
  };
}

/*
{
	"day": "Mon",
	"date": "17",
	"month": "Jul",
	"title": "Mon, 17 Jul",
	"unixTime": 1694889600
}*/
