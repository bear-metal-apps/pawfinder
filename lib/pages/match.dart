import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchPage extends ConsumerStatefulWidget {
  const MatchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MatchPageState();
  }
}

class MatchPageState extends ConsumerState<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Match Page"),
      ),
    );
  }
}
