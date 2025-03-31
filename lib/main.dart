import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:stellar_hp_fe/core/core.dart';

void main() async {
  await DependencyInjection.init(
    rpc: const String.fromEnvironment('rpc'),
    seed: KeyPair.random().secretSeed,
    contractAddress: const String.fromEnvironment('contractAddress'),
  );
  await getIt.isReady<SharedPreferences>();

  runApp(const StellarHpApp());
}

class StellarHpApp extends StatefulWidget {
  const StellarHpApp({super.key});

  @override
  State<StellarHpApp> createState() => _StellarHpAppState();
}

class _StellarHpAppState extends State<StellarHpApp> {
  @override
  void initState() {
    if (kIsWeb) BrowserContextMenu.disableContextMenu();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainProvider>(create: (_) => getIt<MainProvider>()),
        ChangeNotifierProvider<ConsultationProvider>(create: (_) => getIt<ConsultationProvider>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Stellar HP',
        theme: ThemeData(
          useMaterial3: true,
          splashFactory: InkRipple.splashFactory,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: stellarHpGreen),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
