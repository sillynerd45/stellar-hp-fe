import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core.dart';

class MainProvider extends ChangeNotifier {
  // for Home Page
  int todayDateIndex = 0;
  StellarHpDate? chosenDate;
  DailyHealthLogs? chosenDailyHealthLogs;

  // for Data
  UserProfile? userProfile;
  List<StellarHpDate> stellarHpDateList = [];
  String timeZone = '';
  Map<String, YearlyHealthLogs> userHealthLogs = {};

  // for Stellar Update
  int stellarUpdate = 0;

  // for Decryption Progress
  bool isHealthLogDecryptionInProgress = false;
  bool isHealthReportDecryptionInProgress = false;

  void setUserProfile(UserProfile profile) {
    userProfile = profile;
  }

  void setUserHealthLogs(Map<String, YearlyHealthLogs> healthLogs) {
    userHealthLogs = healthLogs;
    chosenDailyHealthLogs = searchDailyHealthLogsData(stellarHpDateList.first.dateTime!);
  }

  void setDateList(List<StellarHpDate> dateList) {
    stellarHpDateList = dateList;
  }

  Future<void> checkEncryptedDataInFirstFiveDateOnHealthLogs() async {
    // set true to prevent userHealthLogs mutation during decryption progress
    isHealthLogDecryptionInProgress = true;
    // set true to prevent healthReportList mutation during decryption progress
    isHealthReportDecryptionInProgress = true;

    for (int i = 0; i < 5; i++) {
      // search log data
      DateTime chosenLogTime = stellarHpDateList[i].dateTime!;
      String year = chosenLogTime.year.toString();
      YearlyHealthLogs yearlyData = userHealthLogs[year] ?? YearlyHealthLogs.fromJson({});
      MonthlyHealthLogs monthlyData = getMonthlyData(chosenLogTime, yearlyData);
      DailyHealthLogs dailyData = getDailyData(chosenLogTime, monthlyData);

      // decrypt if encryptedData still exist
      if (dailyData.encryptedData != null) {
        // decrypt health log data
        String encryptedHealthLogsText = dailyData.encryptedData!;
        String plainHealthLogsText = getIt<HashService>()
            .decrypt(encryptedText: encryptedHealthLogsText, seed: getIt<UserIdService>().getSeed());

        // update daily data
        dailyData = DailyHealthLogs.fromJson(jsonDecode(plainHealthLogsText));

        // update monthly and yearly data
        monthlyData = updateMonthlyData(chosenLogTime, monthlyData, dailyData);
        yearlyData = updateYearlyData(chosenLogTime, yearlyData, monthlyData);

        // update User Health Logs
        userHealthLogs.update(year, (_) => yearlyData, ifAbsent: () => yearlyData);
      }
    }
    checkEncryptedDataInAllDateOnHealthLogs();
  }

  Future<void> checkEncryptedDataInAllDateOnHealthLogs() async {
    for (int i = 5; i < 60; i++) {
      // search log data
      DateTime chosenLogTime = stellarHpDateList[i].dateTime!;
      String year = chosenLogTime.year.toString();
      YearlyHealthLogs yearlyData = userHealthLogs[year] ?? YearlyHealthLogs.fromJson({});
      MonthlyHealthLogs monthlyData = getMonthlyData(chosenLogTime, yearlyData);
      DailyHealthLogs dailyData = getDailyData(chosenLogTime, monthlyData);

      // decrypt if encryptedData still exist
      if (dailyData.encryptedData != null) {
        // decrypt health log data
        String encryptedHealthLogsText = dailyData.encryptedData!;
        String plainHealthLogsText = getIt<HashService>()
            .decrypt(encryptedText: encryptedHealthLogsText, seed: getIt<UserIdService>().getSeed());

        // update daily data
        dailyData = DailyHealthLogs.fromJson(jsonDecode(plainHealthLogsText));

        // update monthly and yearly data
        monthlyData = updateMonthlyData(chosenLogTime, monthlyData, dailyData);
        yearlyData = updateYearlyData(chosenLogTime, yearlyData, monthlyData);

        // update User Health Logs
        userHealthLogs.update(year, (_) => yearlyData, ifAbsent: () => yearlyData);
      }
    }

    // save the new decrypted health logs to local storage
    await getIt<DatabaseService>().saveUserHealthLogsToLocalStorage(userHealthLogs);

    // set false to start allowing userHealthLogs mutation
    isHealthLogDecryptionInProgress = false;
  }

  void setTimeZone(String tZone) {
    timeZone = tZone;
  }

  void setTodayAndChosenDate(int index, StellarHpDate date) {
    todayDateIndex = index;
    chosenDate = date;
  }

  void setStellarUpdate() {
    stellarUpdate = stellarUpdate + 1;
    notifyListeners();
  }

  Future<bool> signingOut() async {
    // prevent function to continue during decryption progress
    if (isHealthLogDecryptionInProgress) return false;

    try {
      await getIt<SharedPreferences>().clear();

      chosenDailyHealthLogs = null;
      userHealthLogs.clear();

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('signingOut $e\n$e');
      return false;
    }
  }

  Map<String, dynamic> getHealthLogsForReport(DateTime dateTime) {
    Map<String, dynamic> result = {};

    String year = dateTime.year.toString();
    YearlyHealthLogs yearlyData = userHealthLogs[year] ?? YearlyHealthLogs.fromJson({});
    MonthlyHealthLogs latestMonthData = getMonthlyData(dateTime, yearlyData);

    DateTime previousDateTime = dateTime.subtract(Duration(days: dateTime.day + 1));
    year = previousDateTime.year.toString();
    yearlyData = userHealthLogs[year] ?? YearlyHealthLogs.fromJson({});
    MonthlyHealthLogs previousMonthData = getMonthlyData(previousDateTime, yearlyData);

    String latestMonthName = DateFormat('MMMM').format(dateTime).toLowerCase();
    result.addEntries({latestMonthName: latestMonthData.toJson()}.entries);

    String previousMonthName = DateFormat('MMMM').format(previousDateTime).toLowerCase();
    result.addEntries({previousMonthName: previousMonthData.toJson()}.entries);

    return result;
  }

  DailyHealthLogs getSetDailyHealthLogs(DateTime dateTime) {
    chosenDailyHealthLogs = searchDailyHealthLogsData(dateTime);
    return chosenDailyHealthLogs!;
  }

  DailyHealthLogs searchDailyHealthLogsData(DateTime dateTime) {
    String year = dateTime.year.toString();
    YearlyHealthLogs yearlyData = userHealthLogs[year] ?? YearlyHealthLogs.fromJson({});
    MonthlyHealthLogs monthlyData = getMonthlyData(dateTime, yearlyData);
    return getDailyData(dateTime, monthlyData);
  }

  Future<bool> saveDailyLog(Object log, DateTime chosenLogTime) async {
    // prevent function to continue during decryption progress
    if (isHealthLogDecryptionInProgress) return false;

    // search data
    String year = chosenLogTime.year.toString();
    YearlyHealthLogs yearlyData = userHealthLogs[year] ?? YearlyHealthLogs.fromJson({});
    MonthlyHealthLogs monthlyData = getMonthlyData(chosenLogTime, yearlyData);
    DailyHealthLogs dailyData = getDailyData(chosenLogTime, monthlyData);

    switch (log) {
      case BodyTemperature e:
        dailyData.bodyTemperature.insert(0, e);
        dailyData.bodyTemperature.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
      case BloodPressure e:
        dailyData.bloodPressure.insert(0, e);
        dailyData.bloodPressure.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
      case Symptom e:
        dailyData.symptom.insert(0, e);
        dailyData.symptom.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
      case Medicine e:
        dailyData.medicine.insert(0, e);
        dailyData.medicine.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
    }

    DateTime currentTime = DateTime.now();

    // save User Health Logs to smart contract
    bool success = await getIt<DatabaseService>().saveDailyLogToSoroban(currentTime, chosenLogTime, dailyData);
    if (!success) return false;

    // update monthly and yearly data
    monthlyData = updateMonthlyData(chosenLogTime, monthlyData, dailyData);
    yearlyData = updateYearlyData(chosenLogTime, yearlyData, monthlyData);

    // update User Health Logs
    userHealthLogs.update(year, (_) => yearlyData, ifAbsent: () => yearlyData);

    // save User Health Logs to local
    bool saveHealthLogsSuccess = await getIt<DatabaseService>().saveUserHealthLogsToLocalStorage(userHealthLogs);
    if (!saveHealthLogsSuccess) return false;

    bool saveHealthLogsUpdatedAtSuccess =
        await getIt<DatabaseService>().saveHealthLogsUpdateAtToLocalStorage(currentTime.millisecondsSinceEpoch);
    if (!saveHealthLogsUpdatedAtSuccess) return false;

    return true;
  }

  Future<bool> deleteHealthLog(Object log, DateTime chosenLogTime) async {
    // prevent function to continue during decryption progress
    if (isHealthLogDecryptionInProgress) return false;

    // search data
    String year = chosenLogTime.year.toString();
    YearlyHealthLogs yearlyData = userHealthLogs[year] ?? YearlyHealthLogs.fromJson({});
    MonthlyHealthLogs monthlyData = getMonthlyData(chosenLogTime, yearlyData);
    DailyHealthLogs dailyData = getDailyData(chosenLogTime, monthlyData);

    switch (log) {
      case BodyTemperature e:
        dailyData.bodyTemperature.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
      case BloodPressure e:
        dailyData.bloodPressure.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
      case Symptom e:
        dailyData.symptom.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
      case Medicine e:
        dailyData.medicine.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
    }

    DateTime currentTime = DateTime.now();

    // save User Health Logs to smart contract
    bool success = await getIt<DatabaseService>().saveDailyLogToSoroban(currentTime, chosenLogTime, dailyData);
    if (!success) return false;

    // update monthly and yearly data
    monthlyData = updateMonthlyData(chosenLogTime, monthlyData, dailyData);
    yearlyData = updateYearlyData(chosenLogTime, yearlyData, monthlyData);

    // update User Health Logs
    userHealthLogs.update(year, (_) => yearlyData, ifAbsent: () => yearlyData);

    // save User Health Logs to local
    bool saveHealthLogsSuccess = await getIt<DatabaseService>().saveUserHealthLogsToLocalStorage(userHealthLogs);
    if (!saveHealthLogsSuccess) return false;

    bool saveHealthLogsUpdatedAtSuccess =
        await getIt<DatabaseService>().saveHealthLogsUpdateAtToLocalStorage(currentTime.millisecondsSinceEpoch);
    if (!saveHealthLogsUpdatedAtSuccess) return false;

    return true;
  }

  Future<bool> updateHealthLog(
    Object newLog,
    DateTime newLogTime,
    Object previousLog,
    DateTime previousLogTime,
  ) async {
    // prevent function to continue during decryption progress
    if (isHealthLogDecryptionInProgress) return false;

    // * Create Cache
    Map<String, YearlyHealthLogs>? cacheLogs = Map<String, YearlyHealthLogs>.of(userHealthLogs);

    // * Current Log Data
    // search and remove previous data
    String previousYear = previousLogTime.year.toString();
    YearlyHealthLogs previousYearlyData = userHealthLogs[previousYear] ?? YearlyHealthLogs.fromJson({});
    MonthlyHealthLogs previousMonthlyData = getMonthlyData(previousLogTime, previousYearlyData);
    DailyHealthLogs previousDailyData = getDailyData(previousLogTime, previousMonthlyData);

    switch (previousLog) {
      case BodyTemperature e:
        previousDailyData.bodyTemperature.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
      case BloodPressure e:
        previousDailyData.bloodPressure.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
      case Symptom e:
        previousDailyData.symptom.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
      case Medicine e:
        previousDailyData.medicine.removeWhere((v) => v.epochTimestamp == e.epochTimestamp);
    }

    // update previous monthly and yearly data
    previousMonthlyData = updateMonthlyData(previousLogTime, previousMonthlyData, previousDailyData);
    previousYearlyData = updateYearlyData(previousLogTime, previousYearlyData, previousMonthlyData);

    // update User Health Logs
    userHealthLogs.update(previousYear, (_) => previousYearlyData, ifAbsent: () => previousYearlyData);

    // * New Log Data
    // search and add new data
    String newYear = newLogTime.year.toString();
    YearlyHealthLogs newYearlyData = userHealthLogs[newYear] ?? YearlyHealthLogs.fromJson({});
    MonthlyHealthLogs newMonthlyData = getMonthlyData(newLogTime, newYearlyData);
    DailyHealthLogs newDailyData = getDailyData(newLogTime, newMonthlyData);

    switch (newLog) {
      case BodyTemperature e:
        newDailyData.bodyTemperature.insert(0, e);
        newDailyData.bodyTemperature.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
      case BloodPressure e:
        newDailyData.bloodPressure.insert(0, e);
        newDailyData.bloodPressure.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
      case Symptom e:
        newDailyData.symptom.insert(0, e);
        newDailyData.symptom.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
      case Medicine e:
        newDailyData.medicine.insert(0, e);
        newDailyData.medicine.sort((a, b) => b.epochTimestamp.compareTo(a.epochTimestamp));
    }

    // update new monthly and yearly data
    newMonthlyData = updateMonthlyData(newLogTime, newMonthlyData, newDailyData);
    newYearlyData = updateYearlyData(newLogTime, newYearlyData, newMonthlyData);

    // update User Health Logs
    userHealthLogs.update(newYear, (_) => newYearlyData, ifAbsent: () => newYearlyData);

    // save User Health Logs to smart contract
    // this function being called last because we need both currentDailyData and newDailyData
    DateTime timeNow = DateTime.now();
    bool success = await getIt<DatabaseService>()
        .updateDailyLogToSoroban(timeNow, previousLogTime, newLogTime, previousDailyData, newDailyData);
    if (!success) {
      // revert logs using cache
      userHealthLogs = Map<String, YearlyHealthLogs>.of(cacheLogs);
      cacheLogs = null;
      return false;
    }

    // save User Health Logs to local
    bool saveHealthLogsSuccess = await getIt<DatabaseService>().saveUserHealthLogsToLocalStorage(userHealthLogs);
    if (!saveHealthLogsSuccess) return false;

    bool saveHealthLogsUpdatedAtSuccess =
        await getIt<DatabaseService>().saveHealthLogsUpdateAtToLocalStorage(timeNow.millisecondsSinceEpoch);
    if (!saveHealthLogsUpdatedAtSuccess) return false;

    return true;
  }

  MonthlyHealthLogs getMonthlyData(DateTime time, YearlyHealthLogs yearlyData) {
    String month = DateFormat('MMMM').format(time).toLowerCase();
    MonthlyHealthLogs? monthlyData;
    switch (month) {
      case 'january':
        monthlyData = yearlyData.january ?? MonthlyHealthLogs.fromJson({});
      case 'february':
        monthlyData = yearlyData.february ?? MonthlyHealthLogs.fromJson({});
      case 'march':
        monthlyData = yearlyData.march ?? MonthlyHealthLogs.fromJson({});
      case 'april':
        monthlyData = yearlyData.april ?? MonthlyHealthLogs.fromJson({});
      case 'may':
        monthlyData = yearlyData.may ?? MonthlyHealthLogs.fromJson({});
      case 'june':
        monthlyData = yearlyData.june ?? MonthlyHealthLogs.fromJson({});
      case 'july':
        monthlyData = yearlyData.july ?? MonthlyHealthLogs.fromJson({});
      case 'august':
        monthlyData = yearlyData.august ?? MonthlyHealthLogs.fromJson({});
      case 'september':
        monthlyData = yearlyData.september ?? MonthlyHealthLogs.fromJson({});
      case 'october':
        monthlyData = yearlyData.october ?? MonthlyHealthLogs.fromJson({});
      case 'november':
        monthlyData = yearlyData.november ?? MonthlyHealthLogs.fromJson({});
      case 'december':
        monthlyData = yearlyData.december ?? MonthlyHealthLogs.fromJson({});
    }
    if (monthlyData == null) return MonthlyHealthLogs.fromJson({});
    return monthlyData;
  }

  DailyHealthLogs getDailyData(DateTime time, MonthlyHealthLogs monthlyData) {
    String day = DateFormat('dd').format(time).toLowerCase();
    DailyHealthLogs? dailyData;
    switch (day) {
      case '01':
        dailyData = monthlyData.d1 ?? DailyHealthLogs.fromJson({});
      case '02':
        dailyData = monthlyData.d2 ?? DailyHealthLogs.fromJson({});
      case '03':
        dailyData = monthlyData.d3 ?? DailyHealthLogs.fromJson({});
      case '04':
        dailyData = monthlyData.d4 ?? DailyHealthLogs.fromJson({});
      case '05':
        dailyData = monthlyData.d5 ?? DailyHealthLogs.fromJson({});
      case '06':
        dailyData = monthlyData.d6 ?? DailyHealthLogs.fromJson({});
      case '07':
        dailyData = monthlyData.d7 ?? DailyHealthLogs.fromJson({});
      case '08':
        dailyData = monthlyData.d8 ?? DailyHealthLogs.fromJson({});
      case '09':
        dailyData = monthlyData.d9 ?? DailyHealthLogs.fromJson({});
      case '10':
        dailyData = monthlyData.d10 ?? DailyHealthLogs.fromJson({});
      case '11':
        dailyData = monthlyData.d11 ?? DailyHealthLogs.fromJson({});
      case '12':
        dailyData = monthlyData.d12 ?? DailyHealthLogs.fromJson({});
      case '13':
        dailyData = monthlyData.d13 ?? DailyHealthLogs.fromJson({});
      case '14':
        dailyData = monthlyData.d14 ?? DailyHealthLogs.fromJson({});
      case '15':
        dailyData = monthlyData.d15 ?? DailyHealthLogs.fromJson({});
      case '16':
        dailyData = monthlyData.d16 ?? DailyHealthLogs.fromJson({});
      case '17':
        dailyData = monthlyData.d17 ?? DailyHealthLogs.fromJson({});
      case '18':
        dailyData = monthlyData.d18 ?? DailyHealthLogs.fromJson({});
      case '19':
        dailyData = monthlyData.d19 ?? DailyHealthLogs.fromJson({});
      case '20':
        dailyData = monthlyData.d20 ?? DailyHealthLogs.fromJson({});
      case '21':
        dailyData = monthlyData.d21 ?? DailyHealthLogs.fromJson({});
      case '22':
        dailyData = monthlyData.d22 ?? DailyHealthLogs.fromJson({});
      case '23':
        dailyData = monthlyData.d23 ?? DailyHealthLogs.fromJson({});
      case '24':
        dailyData = monthlyData.d24 ?? DailyHealthLogs.fromJson({});
      case '25':
        dailyData = monthlyData.d25 ?? DailyHealthLogs.fromJson({});
      case '26':
        dailyData = monthlyData.d26 ?? DailyHealthLogs.fromJson({});
      case '27':
        dailyData = monthlyData.d27 ?? DailyHealthLogs.fromJson({});
      case '28':
        dailyData = monthlyData.d28 ?? DailyHealthLogs.fromJson({});
      case '29':
        dailyData = monthlyData.d29 ?? DailyHealthLogs.fromJson({});
      case '30':
        dailyData = monthlyData.d30 ?? DailyHealthLogs.fromJson({});
      case '31':
        dailyData = monthlyData.d31 ?? DailyHealthLogs.fromJson({});
    }
    if (dailyData == null) return DailyHealthLogs.fromJson({});
    return dailyData;
  }

  YearlyHealthLogs updateYearlyData(
    DateTime time,
    YearlyHealthLogs yearlyData,
    MonthlyHealthLogs monthlyData,
  ) {
    String month = DateFormat('MMMM').format(time).toLowerCase();
    switch (month) {
      case 'january':
        yearlyData = yearlyData.copyWith(january: monthlyData);
      case 'february':
        yearlyData = yearlyData.copyWith(february: monthlyData);
      case 'march':
        yearlyData = yearlyData.copyWith(march: monthlyData);
      case 'april':
        yearlyData = yearlyData.copyWith(april: monthlyData);
      case 'may':
        yearlyData = yearlyData.copyWith(may: monthlyData);
      case 'june':
        yearlyData = yearlyData.copyWith(june: monthlyData);
      case 'july':
        yearlyData = yearlyData.copyWith(july: monthlyData);
      case 'august':
        yearlyData = yearlyData.copyWith(august: monthlyData);
      case 'september':
        yearlyData = yearlyData.copyWith(september: monthlyData);
      case 'october':
        yearlyData = yearlyData.copyWith(october: monthlyData);
      case 'november':
        yearlyData = yearlyData.copyWith(november: monthlyData);
      case 'december':
        yearlyData = yearlyData.copyWith(december: monthlyData);
    }
    return yearlyData;
  }

  MonthlyHealthLogs updateMonthlyData(
    DateTime time,
    MonthlyHealthLogs monthlyData,
    DailyHealthLogs dailyData,
  ) {
    String day = DateFormat('dd').format(time).toLowerCase();
    switch (day) {
      case '01':
        monthlyData = monthlyData.copyWith(d1: dailyData);
      case '02':
        monthlyData = monthlyData.copyWith(d2: dailyData);
      case '03':
        monthlyData = monthlyData.copyWith(d3: dailyData);
      case '04':
        monthlyData = monthlyData.copyWith(d4: dailyData);
      case '05':
        monthlyData = monthlyData.copyWith(d5: dailyData);
      case '06':
        monthlyData = monthlyData.copyWith(d6: dailyData);
      case '07':
        monthlyData = monthlyData.copyWith(d7: dailyData);
      case '08':
        monthlyData = monthlyData.copyWith(d8: dailyData);
      case '09':
        monthlyData = monthlyData.copyWith(d9: dailyData);
      case '10':
        monthlyData = monthlyData.copyWith(d10: dailyData);
      case '11':
        monthlyData = monthlyData.copyWith(d11: dailyData);
      case '12':
        monthlyData = monthlyData.copyWith(d12: dailyData);
      case '13':
        monthlyData = monthlyData.copyWith(d13: dailyData);
      case '14':
        monthlyData = monthlyData.copyWith(d14: dailyData);
      case '15':
        monthlyData = monthlyData.copyWith(d15: dailyData);
      case '16':
        monthlyData = monthlyData.copyWith(d16: dailyData);
      case '17':
        monthlyData = monthlyData.copyWith(d17: dailyData);
      case '18':
        monthlyData = monthlyData.copyWith(d18: dailyData);
      case '19':
        monthlyData = monthlyData.copyWith(d19: dailyData);
      case '20':
        monthlyData = monthlyData.copyWith(d20: dailyData);
      case '21':
        monthlyData = monthlyData.copyWith(d21: dailyData);
      case '22':
        monthlyData = monthlyData.copyWith(d22: dailyData);
      case '23':
        monthlyData = monthlyData.copyWith(d23: dailyData);
      case '24':
        monthlyData = monthlyData.copyWith(d24: dailyData);
      case '25':
        monthlyData = monthlyData.copyWith(d25: dailyData);
      case '26':
        monthlyData = monthlyData.copyWith(d26: dailyData);
      case '27':
        monthlyData = monthlyData.copyWith(d27: dailyData);
      case '28':
        monthlyData = monthlyData.copyWith(d28: dailyData);
      case '29':
        monthlyData = monthlyData.copyWith(d29: dailyData);
      case '30':
        monthlyData = monthlyData.copyWith(d30: dailyData);
      case '31':
        monthlyData = monthlyData.copyWith(d31: dailyData);
    }
    return monthlyData;
  }
}
