import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_hp_fe/core/core.dart';

void main() async {
  await DependencyInjection.init(
    rpc: const String.fromEnvironment('rpc'),
    seed: const String.fromEnvironment('seed'),
    contractAddress: const String.fromEnvironment('contractAddress'),
  );
  await getIt.isReady<SharedPreferences>();

  runApp(const StellarHpApp());
}

class StellarHpApp extends StatelessWidget {
  const StellarHpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainProvider>(create: (_) => getIt<MainProvider>()),
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
