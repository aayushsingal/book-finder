import 'package:flutter/material.dart';
import 'core/utils/constants.dart';
import 'injection_container.dart' as di;
import 'features/books/presentation/pages/book_search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BookSearchPage(),
      debugShowCheckedModeBanner: true,
    );
  }
}
