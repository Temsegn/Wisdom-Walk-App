import 'package:flutter/material.dart';

class Reflection {
  final String id;
  final String verseReference;
  final String content;
  final DateTime createdAt;

  Reflection({
    required this.id,
    required this.verseReference,
    required this.content,
    required this.createdAt,
  });
}

class ReflectionProvider with ChangeNotifier {
  List<Reflection> _reflections = [];

  List<Reflection> get reflections => _reflections;

  void addReflection(String verseReference, String content) {
    final reflection = Reflection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      verseReference: verseReference,
      content: content,
      createdAt: DateTime.now(),
    );
    _reflections.add(reflection);
    notifyListeners();
  }
}
