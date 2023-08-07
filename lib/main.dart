// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
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
      routes: {
        '/news': (context) => const NewsBreadCrumbWidget(),
      },
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;
  String uuid;

  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  //
  // Declare variables.
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get item => UnmodifiableListView(_items);

  ///
  /// Add a breadcrumb.
  ///
  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  ///
  /// Delete all breadcrumbs.
  ///
  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbWidget({super.key, required this.breadCrumbs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map((breadCrumb) {
        return Text(
          breadCrumb.title,
          style: TextStyle(
            color: breadCrumb.isActive ? Colors.blue : Colors.black,
          ),
        );
      }).toList(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home page"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbWidget(breadCrumbs: value.item);
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/news');
            },
            child: const Text(
              "Add new bread crumb",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () {
              context.read<BreadCrumbProvider>().reset();
            },
            child: const Text(
              "Reset",
            ),
          ),
        ],
      ),
    );
  }
}

class NewsBreadCrumbWidget extends StatefulWidget {
  const NewsBreadCrumbWidget({super.key});

  @override
  State<NewsBreadCrumbWidget> createState() => _NewsBreadCrumbWidgetState();
}

class _NewsBreadCrumbWidgetState extends State<NewsBreadCrumbWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new bread crumb"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
                hintText: "Enter a new bread crumb here ..."),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                final breadCrumb =
                    BreadCrumb(isActive: false, name: _controller.text.trim());
                context.read<BreadCrumbProvider>().add(breadCrumb);
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Add",
            ),
          ),
        ],
      ),
    );
  }
}
