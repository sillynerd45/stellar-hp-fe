import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stellar_hp_fe/core/core.dart';

class DatabaseService {
  Future<bool> saveUserHealthLogsToLocalStorage(Map<String, YearlyHealthLogs> userData) async {
    try {
      Map<String, dynamic> encodedUserData = {};

      for (String k in userData.keys) {
        encodedUserData.update(
          k,
          (_) => userData[k]?.toJson(),
          ifAbsent: () => userData[k]?.toJson(),
        );
      }

      await getIt<SharedPreferences>().setString(keyHealthLogs, jsonEncode(encodedUserData));
      return true;
    } catch (e, s) {
      if (kDebugMode) debugPrint('saveUserHealthLogsToLocalStorage $e\n$s');
      return false;
    }
  }

  Future<bool> saveHealthLogsUpdateAtToLocalStorage(int healthLogsUpdateAt) async {
    try {
      await getIt<SharedPreferences>().setString(keyHealthLogsUpdateAt, '$healthLogsUpdateAt');
      return true;
    } catch (e, s) {
      if (kDebugMode) debugPrint('saveHealthLogsUpdateAtToLocalStorage $e\n$s');
      return false;
    }
  }

  Future<bool> saveDailyLogToSoroban(
    DateTime currentTime,
    DateTime chosenLogTime,
    DailyHealthLogs dailyData,
  ) async {
    // TODO: invoke SMART CONTRACT insert-log here
    return true;
  }

  Future<bool> updateDailyLogToSoroban(
    DateTime timeNow,
    DateTime previousLogTime,
    DateTime newLogTime,
    DailyHealthLogs previousDailyData,
    DailyHealthLogs newDailyData,
  ) async {
    // TODO: invoke SMART CONTRACT insert-log here
    // TODO: handle the different of log times
    return true;
  }

  Future<Map<String, YearlyHealthLogs>?> loadUserHealthLogsFromLocalStorage() async {
    try {
      String? value = getIt<SharedPreferences>().getString(keyHealthLogs);
      if (value == null) return null;

      Map<String, dynamic> decodedUserData = jsonDecode(value);
      Map<String, YearlyHealthLogs> userData = {};

      for (String k in decodedUserData.keys) {
        userData.update(
          k,
          (_) => YearlyHealthLogs.fromJson(decodedUserData[k]),
          ifAbsent: () => YearlyHealthLogs.fromJson(decodedUserData[k]),
        );
      }

      return userData;
    } catch (e, s) {
      if (kDebugMode) debugPrint('loadUserHealthLogsFromLocalStorage $e\n$s');
      return null;
    }
  }

  Future<int> loadHealthLogsUpdateAtFromLocalStorage() async {
    try {
      String? value = getIt<SharedPreferences>().getString(keyHealthLogsUpdateAt);
      if (value == null) return 0;
      return int.tryParse(value) ?? 0;
    } catch (e, s) {
      if (kDebugMode) debugPrint('loadHealthLogsUpdateAtFromLocalStorage $e\n$s');
      return 0;
    }
  }

  Future<Map<String, YearlyHealthLogs>?> loadUserHealthLogs(String publicKey) async {
    try {
      // check Health Logs Last Update from Local Storage
      Map<String, YearlyHealthLogs>? healthLogs = await getIt<DatabaseService>().loadUserHealthLogsFromLocalStorage();

      // TODO: [ IMPORTANT ] here fetch data from soroban

      // TODO: check if data in Soroban is more updated than Local Storage

      return healthLogs;
    } catch (e, s) {
      if (kDebugMode) debugPrint('loadUserHealthLogs $e\n$s');
      return null;
    }
  }

  Future<bool> registerUserProfileDataToContract(DateTime time, UserProfile userProfile) async {
    try {
      bool isSignUpSuccess =
          await getIt<HpSignUp>().invoke(publicKey: getIt<UserIdService>().getPublicKey(), userProfile: userProfile);
      if (!isSignUpSuccess) return false;

      // save Profile to Local Storage
      await saveProfileToLocalStorage(userProfile);
      await saveProfileUpdateAtToLocalStorage(time.millisecondsSinceEpoch);

      return true;
    } catch (e, s) {
      if (kDebugMode) debugPrint('registerUserProfileDataToContract $e\n$s');
      return false;
    }
  }

  Future<bool> saveProfileToLocalStorage(UserProfile userProfile) async {
    try {
      await getIt<SharedPreferences>().setString(keyUserProfile, jsonEncode(userProfile.toJson()));
      return true;
    } catch (e, s) {
      if (kDebugMode) debugPrint('saveProfileToLocalStorage $e\n$s');
      return false;
    }
  }

  Future<bool> saveProfileUpdateAtToLocalStorage(int profileUpdateAt) async {
    try {
      await getIt<SharedPreferences>().setString(keyUserProfileUpdateAt, '$profileUpdateAt');
      return true;
    } catch (e, s) {
      if (kDebugMode) debugPrint('saveProfileUpdateAtToLocalStorage $e\n$s');
      return false;
    }
  }

  Future<UserProfile?> getUserProfileDataFromContract() async {
    try {
      return await getIt<HpGetProfile>().invoke(publicKey: getIt<UserIdService>().getPublicKey());
    } catch (e, s) {
      if (kDebugMode) debugPrint('getUserProfileDataFromContract $e\n$s');
      return null;
    }
  }
}
