import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

void main() async {
  await DependencyInjection.init(
    rpc: const String.fromEnvironment('rpc'),
    contractAddress: const String.fromEnvironment('contractAddress'),
  );

  runApp(const StellarHpApp());
}

class StellarHpApp extends StatelessWidget {
  const StellarHpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    // TODO: PLATO
    // await getIt<HpSignUp>().invoke(publicKey: 'GB3NWHOV6POCYEVH6B74V5KM6A22T4J36Z5EMEHHGP6SGTMCD7SEVQGM');
    await getIt<HpGetLogHash>().invoke(publicKey: 'GB3NWHOV6POCYEVH6B74V5KM6A22T4J36Z5EMEHHGP6SGTMCD7SEVQGM');

    // TODO: ARES
    // await getIt<HpSignUp>().invoke(publicKey: 'GAN2QRLHTKDIFZYU3GSQ3AYSJDGF6H6KUWCUPH2PXJGDVVKONGZXPPNG');
    await getIt<HpGetLogHash>().invoke(publicKey: 'GAN2QRLHTKDIFZYU3GSQ3AYSJDGF6H6KUWCUPH2PXJGDVVKONGZXPPNG');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
