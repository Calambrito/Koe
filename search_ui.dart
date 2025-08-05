import 'package:flutter/material.dart';
import 'package:standard_searchbar/new/standard_search_anchor.dart';
import 'package:standard_searchbar/new/standard_search_bar.dart';
import 'package:standard_searchbar/new/standard_suggestion.dart';
import 'package:standard_searchbar/new/standard_suggestions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Koe'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(
                    0xFFB3A3BA,
                  ), // Purple color matching your background
                  width: 2.0, // Thickness of the line
                ),
              ),
            ),
          ),
        ),
        body: const SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 100),
              SizedBox(
                width: 360,
                child: StandardSearchAnchor(
                  searchBar: StandardSearchBar(bgColor: Color(0xFFD9D8D9)),
                  suggestions: StandardSuggestions(
                    suggestions: [
                      StandardSuggestion(text: 'suggestion 1'),
                      StandardSuggestion(text: 'suggestion 2'),
                      StandardSuggestion(text: 'suggestion 3'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Color(0xFFB3A3BA),
      ),
    );
  }
}
