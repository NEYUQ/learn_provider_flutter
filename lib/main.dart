import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

@immutable
class BaseObject {
  final String id;
  final String lastUpdated;
  BaseObject()
      : id = const Uuid().v1(),
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;

  late CheapObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSubs;

  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveStreamSubs;

  CheapObject get cheapObject => _cheapObject;
  ExpensiveObject get expensiveObject => _expensiveObject;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }
  ///
  /// Start streams.
  ///
  void start() {
    _cheapObjectStreamSubs =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _cheapObject = CheapObject();
      notifyListeners();
    });

    _expensiveStreamSubs =
        Stream.periodic(const Duration(seconds: 10)).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }
  ///
  /// Stop streams.
  ///
  void stop() {
    _cheapObjectStreamSubs.cancel();
    _expensiveStreamSubs.cancel();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print("truong dinh quyen");
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: CheapWidget(),
              ),
              Expanded(
                child: ExpensiveWidget(),
              ),
            ],
          ),
          Row(
            children: const [
              Expanded(
                child: ObjectProviderWidget(),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<ObjectProvider>().stop();
                },
                child: const Text(
                  "Stop",
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<ObjectProvider>().start();
                },
                child: const Text(
                  "Start",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
      (value) => value.cheapObject,
    );
    print("cheap");
    return Container(
      height: 100,
      color: Colors.yellow,
      child: Column(
        children: [
          const Text("Cheap Widget"),
          const Text("Last updated"),
          Text(cheapObject.lastUpdated),
        ],
      ),
    );
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
      (value) => value.expensiveObject,
    );
    print("expensive");
    return Container(
      height: 100,
      color: Colors.blue,
      child: Column(
        children: [
          const Text("Expensive Widget"),
          const Text("Last updated"),
          Text(expensiveObject.lastUpdated),
        ],
      ),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();
    print("provider");
    return Container(
      height: 100,
      color: Colors.purple,
      child: Column(
        children: [
          const Text("Object Widget"),
          const Text("ID"),
          Text(provider.id),
        ],
      ),
    );
  }
}
