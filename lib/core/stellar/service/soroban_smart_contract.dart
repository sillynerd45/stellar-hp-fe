import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

class SorobanSmartContract {
  final SorobanServer soroban;
  final Network network;
  final String contractID;
  final String contractADDRESS;

  SorobanSmartContract({
    required this.soroban,
    required this.network,
    required this.contractID,
    required this.contractADDRESS,
  });

  static String eventContract = 'contract';

  Timer? timer;
  bool timerRunning = false;
  bool taskRunning = false;
  int currentLedger = 0;

  InvokeHostFunctionOperation buildOperation(String functionName, List<XdrSCVal> arguments) {
    InvokeContractHostFunction hostFunction = InvokeContractHostFunction(
      contractID,
      functionName,
      arguments: arguments,
    );
    return InvokeHostFuncOpBuilder(hostFunction).build();
  }

  void listenToEvent() {
    if (timerRunning) return;

    timerRunning = true;
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (taskRunning || !timerRunning) {
        return;
      }

      taskRunning = true;
      try {
        if (currentLedger == 0) {
          currentLedger = await getLatestLedgerSequence();
        }
        await getStellarHpEvents();
      } catch (e, s) {
        if (kDebugMode) debugPrint('listenToEvent : $e\n$s');
      } finally {
        taskRunning = false;
      }
    });
  }

  void stopListen() {
    timerRunning = false;
    timer?.cancel();
  }

  Future<int> getLatestLedgerSequence() async {
    try {
      GetLatestLedgerResponse data = await soroban.getLatestLedger();
      return data.sequence ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> getStellarHpEvents() async {
    try {
      // search events
      // search ledger MUST start at currentLedger + 1
      var (List<Consult>? events, int? latestLedger, String? error) = await searchEvent(currentLedger + 1);
      if (error != null) return;

      if (currentLedger == latestLedger!) return;

      // update current ledger
      currentLedger = latestLedger;

      // process event received
      List<Consult> eventList = processEvents(events!);

      // process events received & notify listener
      getIt<ConsultationProvider>().updateList(eventList);
    } catch (e, s) {
      if (kDebugMode) debugPrint('getStellarHpEvents $e\n$s');
    }
  }

  Future<(List<Consult>?, int?, String?)> searchEvent(int ledger) async {
    // create get event request
    GetEventsRequest getEventsRequest = GetEventsRequest(
      (ledger - 10000),
      paginationOptions: PaginationOptions(limit: 10000),
      filters: [
        EventFilter(type: eventContract, contractIds: [contractADDRESS]),
      ],
    );

    // get soroban contract events
    GetEventsResponse getEventsResponse = await soroban.getEvents(getEventsRequest);

    if (getEventsResponse.isErrorResponse) {
      String errorCode = '${getEventsResponse.error?.code}';
      String errorMessage = '${getEventsResponse.error?.message}';
      if (kDebugMode) debugPrint('searchEvent ERROR: $errorCode\n$errorMessage');
      return (null, null, '$errorCode\n$errorMessage');
    }

    // process result
    String userLogHash = getIt<MainProvider>().userProfile!.logHash!;
    AccountType accountType = getIt<MainProvider>().userProfile!.accountType!;
    int latestLedger = getEventsResponse.latestLedger!;
    List<EventInfo> eventInfo = getEventsResponse.events ?? [];
    List<Consult> eventList = [];

    for (EventInfo info in eventInfo) {
      String eventName = '';

      // event name
      for (String topic in info.topic) {
        XdrSCVal xdrSCVal = XdrSCVal.fromBase64EncodedXdrString(topic);
        if (xdrSCVal.sym == null) continue;
        eventName = xdrSCVal.sym!;
      }

      // event data
      XdrSCVal xdrSCVal = XdrSCVal.fromBase64EncodedXdrString(info.value);
      if (xdrSCVal.map == null) continue;

      switch (eventName) {
        case 'request':
          ConsultRequest e = ConsultRequest.parse(xdrSCVal);
          if (accountType == AccountType.user) if (e.fromUser == userLogHash) eventList.add(e);
          if (accountType == AccountType.healthWorker) if (e.toDoctor == userLogHash) eventList.add(e);
        case 'accepted':
          ConsultAccepted e = ConsultAccepted.parse(xdrSCVal);
          if (accountType == AccountType.user) if (e.toUser == userLogHash) eventList.add(e);
          if (accountType == AccountType.healthWorker) if (e.fromDoctor == userLogHash) eventList.add(e);
        case 'data':
          ConsultData e = ConsultData.parse(xdrSCVal);
          if (accountType == AccountType.user) if (e.fromUser == userLogHash) eventList.add(e);
          if (accountType == AccountType.healthWorker) if (e.toDoctor == userLogHash) eventList.add(e);
        case 'result':
          ConsultResult e = ConsultResult.parse(xdrSCVal);
          if (accountType == AccountType.user) if (e.toUser == userLogHash) eventList.add(e);
          if (accountType == AccountType.healthWorker) if (e.fromDoctor == userLogHash) eventList.add(e);
      }
    }

    return (eventList, latestLedger, null);
  }

  List<Consult> processEvents(List<Consult> consults) {
    final consultGroupMap = <String, List<Consult>>{};
    final earliestIndexMap = <String, int>{};

    for (var i = 0; i < consults.length; i++) {
      final consult = consults[i];
      final consultHash = consult.consultHash;
      consultGroupMap.putIfAbsent(consultHash, () => []).add(consult);
      earliestIndexMap.putIfAbsent(consultHash, () => i);
    }

    final processedGroups = <_GroupData>[];

    consultGroupMap.forEach((hash, events) {
      events.sort((a, b) => getPriority(a).compareTo(getPriority(b)));
      final lastEvent = events.last;
      events.clear();
      events.add(lastEvent);
      final earliestIndex = earliestIndexMap[hash]!;
      processedGroups.add(_GroupData(earliestIndex, events));
    });

    processedGroups.sort((a, b) => a.earliestIndex.compareTo(b.earliestIndex));

    return processedGroups.expand((g) => g.events).toList();
  }

  int getPriority(Consult event) {
    if (event is ConsultRequest) return 1;
    if (event is ConsultAccepted) return 2;
    if (event is ConsultData) return 3;
    if (event is ConsultResult) return 4;
    return 1;
  }
}

class _GroupData {
  final int earliestIndex;
  final List<Consult> events;

  _GroupData(this.earliestIndex, this.events);
}
