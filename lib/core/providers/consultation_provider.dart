import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core.dart';

class ConsultationProvider extends ChangeNotifier {
  List<Consult> consultList = [];

  // for Stellar Update
  int stellarUpdate = 0;

  Map<String, String> consultationHashIdentifier = {};
  Map<String, HpSecureSharedUser> onProgressConsultMapUSER = {};
  Map<String, HpSecureSharedDoctor> onProgressConsultMapDOCTOR = {};

  bool processConsultation = false;

  String tempUserName = '';
  String tempUserRSA = '';
  String tempUserDataHash = '';
  String tempConsultHash = '';
  ConsultData? tempConsultData;
  String tempDiagnosis = '';

  Future<void> updateList(List<Consult> list) async {
    if (!areConsultListsEqual(consultList, list)) {
      List<Consult> getNewConsultsList = getNewConsults(consultList, list);
      await processUniqueConsult(getNewConsultsList);
      consultList = list;
      setStellarUpdate();
    }
  }

  void setStellarUpdate() {
    stellarUpdate = stellarUpdate + 1;
    notifyListeners();
  }

  bool areConsultListsEqual(List<Consult> list1, List<Consult> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  String getHashID(String hashKey) {
    return consultationHashIdentifier[hashKey] ?? '-';
  }

  void insertHashID(String hashKey, String value) {
    consultationHashIdentifier[hashKey] = value;
  }

  void deleteHashID(String hashKey) {
    consultationHashIdentifier.remove(hashKey);
  }

  List<Consult> getNewConsults(List<Consult> oldList, List<Consult> newList) {
    // Convert old list to a Set for O(1) lookups
    final oldSet = oldList.toSet();

    // Filter new list to include only elements not in the oldSet
    return newList.where((consult) => !oldSet.contains(consult)).toList();
  }

  Future<void> processUniqueConsult(List<Consult> uniqueList) async {
    AccountType userAccountType = getIt<MainProvider>().userProfile!.accountType!;
    if (userAccountType == AccountType.healthWorker) return;

    for (Consult consult in uniqueList) {
      if (consult is ConsultAccepted) {
        var data = onProgressConsultMapUSER[consult.fromDoctor];
        if (data == null) continue;
        await sendConsultData(consult);
      }
    }
  }

  Future<void> createNewConsult({
    required String doctorHash,
    required String dataPeriod,
  }) async {
    if (processConsultation) return;
    processConsultation = true;

    String name = getIt<MainProvider>().userProfile!.name!;
    String userHash = getIt<MainProvider>().userProfile!.logHash!;
    int daysBack = 0;
    if (dataPeriod == '3 Days') {
      daysBack = 3;
    } else if (dataPeriod == '5 Days') {
      daysBack = 5;
    } else if (dataPeriod == '7 Days') {
      daysBack = 7;
    }

    AsymmetricKeyPair keyPair = CryptoUtils.generateRSAKeyPair(keySize: 1024);
    HpSecureSharedUser secureShared = HpSecureSharedUser(
      doctorHash: doctorHash,
      publicRSA: getIt<HashService>().getPublicKeyPEM(keyPair),
      privateRSA: getIt<HashService>().getPrivateKeyPEM(keyPair),
      logs: getIt<MainProvider>().filterLogsByDays(getIt<MainProvider>().userHealthLogs, daysBack),
      dataPeriod: dataPeriod,
    );

    bool isSuccess = await getIt<HpConsultRequest>().invoke(
      publicKey: getIt<UserIdService>().getPublicKey(),
      doctorHash: doctorHash,
      userHash: userHash,
      name: name,
      dataPeriod: dataPeriod,
    );

    if (!isSuccess) {
      processConsultation = false;
      return;
    }

    // save data to map for later use
    onProgressConsultMapUSER[doctorHash] = secureShared;
    await saveConsultUser();

    processConsultation = false;
  }

  Future<void> sendConsultData(ConsultAccepted consult) async {
    String name = getIt<MainProvider>().userProfile!.name!;
    String userHash = getIt<MainProvider>().userProfile!.logHash!;

    await getIt<HpConsultData>().invoke(
      publicKey: getIt<UserIdService>().getPublicKey(),
      name: name,
      doctorHash: consult.fromDoctor,
      userHash: userHash,
      userRSA: onProgressConsultMapUSER[consult.fromDoctor]!.publicRSA,
      doctorRSA: getIt<HashService>().addPemHeaders(consult.doctorRsa),
      data: onProgressConsultMapUSER[consult.fromDoctor]!.logs,
      consultHash: consult.consultHash,
    );
  }

  Future<String> acceptNewConsult({
    required String userHash,
  }) async {
    AsymmetricKeyPair keyPair = CryptoUtils.generateRSAKeyPair(keySize: 1024);
    HpSecureSharedDoctor secureShared = HpSecureSharedDoctor(
      userHash: userHash,
      publicRSA: getIt<HashService>().getPublicKeyPEM(keyPair),
      privateRSA: getIt<HashService>().getPrivateKeyPEM(keyPair),
    );
    // save data to map for later use
    onProgressConsultMapDOCTOR[userHash] = secureShared;
    await saveConsultDoctor();
    return secureShared.publicRSA;
  }

  void clearTempData() {
    tempUserName = '';
    tempUserRSA = '';
    tempUserDataHash = '';
    tempConsultHash = '';
    tempConsultData = null;
    tempDiagnosis = '';
  }

  Future<bool> prepareShowUserHealthLogs({
    required String name,
    required String userRSA,
    required String userHash,
    required String dataHash,
    required String consultHash,
    required ConsultData consult,
  }) async {
    String? rsaEncodedUserLogs =
        await getIt<HpGetSingleLog>().invoke(publicKey: getIt<UserIdService>().getPublicKey(), dataHash: dataHash);
    if (rsaEncodedUserLogs == null) return false;

    tempUserName = name;
    tempUserRSA = userRSA;
    tempUserDataHash = dataHash;
    tempConsultHash = consultHash;
    tempConsultData = consult;

    Map<String, YearlyHealthLogs> userHealthLogData = getIt<HashService>()
        .decodeYearlyHealthLogsRSA(rsaEncodedUserLogs, onProgressConsultMapDOCTOR[userHash]!.privateRSA);
    getIt<MainProvider>().setUserHealthLogs(userHealthLogData);
    return true;
  }

  Future<bool> prepareShowDoctorDiagnosis({
    required String doctorHash,
    required String diagnosisHash,
  }) async {
    String? rsaEncodedDiagnosis =
        await getIt<HpGetSingleLog>().invoke(publicKey: getIt<UserIdService>().getPublicKey(), dataHash: diagnosisHash);
    if (rsaEncodedDiagnosis == null) return false;

    tempDiagnosis = getIt<HashService>().decryptRSA(
        encryptedText: rsaEncodedDiagnosis, privateKeyPem: onProgressConsultMapUSER[doctorHash]!.privateRSA);
    return true;
  }

  Future<void> saveConsultUser() async {
    final userJson = onProgressConsultMapUSER.map((key, value) => MapEntry(key, value.toJson()));
    await getIt<SharedPreferences>().setString(keyConsultMapUSER, jsonEncode(userJson));
  }

  Future<void> saveConsultDoctor() async {
    final doctorJson = onProgressConsultMapDOCTOR.map((key, value) => MapEntry(key, value.toJson()));
    await getIt<SharedPreferences>().setString(keyConsultMapDOCTOR, jsonEncode(doctorJson));
  }

  Future<void> loadConsultFromStorage() async {
    final userJson = getIt<SharedPreferences>().getString(keyConsultMapUSER);
    Map<String, HpSecureSharedUser> users = {};
    if (userJson != null) {
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      users = decoded.map((key, value) => MapEntry(key, HpSecureSharedUser.fromJson(value)));
    }
    onProgressConsultMapUSER = users;

    final doctorJson = getIt<SharedPreferences>().getString(keyConsultMapDOCTOR);
    Map<String, HpSecureSharedDoctor> doctors = {};
    if (doctorJson != null) {
      final decoded = jsonDecode(doctorJson) as Map<String, dynamic>;
      doctors = decoded.map((key, value) => MapEntry(key, HpSecureSharedDoctor.fromJson(value)));
    }
    onProgressConsultMapDOCTOR = doctors;
  }
}
