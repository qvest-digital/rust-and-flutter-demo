import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class TestableWidgetWrapper extends StatelessWidget {
  final Widget testSubject;
  final List<SingleChildWidget> providers;

  const TestableWidgetWrapper({
    super.key,
    required this.testSubject,
    required this.providers,
  });

  @override
  Widget build(BuildContext context) => MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          home: MultiProvider(
            providers: providers,
            child: testSubject,
          ),
        ),
      );
}
