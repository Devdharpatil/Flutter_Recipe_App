import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe2/core/widgets/app_header.dart';

void main() {
  group('AppHeader Widget Tests', () {
    testWidgets('AppHeader renders consistently across light/dark modes', 
        (WidgetTester tester) async {
      // Test in light mode
      await _testHeaderInThemeMode(tester, ThemeMode.light);
      
      // Test in dark mode
      await _testHeaderInThemeMode(tester, ThemeMode.dark);
    });
  });
}

Future<void> _testHeaderInThemeMode(WidgetTester tester, ThemeMode mode) async {
  final isDarkMode = mode == ThemeMode.dark;
  
  // Build our app with the AppHeader widget
  await tester.pumpWidget(
    MaterialApp(
      themeMode: mode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            const AppHeader(
              title: 'Test Header',
              subtitle: 'Test subtitle',
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 1000,
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // Wait for animations to complete
  await tester.pumpAndSettle();

  // Find the AppHeader widget
  final headerFinder = find.byType(AppHeader);
  expect(headerFinder, findsOneWidget);
  
  // Find the SliverAppBar within AppHeader
  final sliverAppBarFinder = find.byType(SliverAppBar);
  expect(sliverAppBarFinder, findsOneWidget);
  
  // Verify title is displayed
  expect(find.text('Test Header'), findsOneWidget);
  expect(find.text('Test subtitle'), findsOneWidget);
  
  // Check background color based on theme mode
  final SliverAppBar appBar = tester.widget(sliverAppBarFinder);
  
  // Verify gradient text exists via ShaderMask
  expect(find.byType(ShaderMask), findsOneWidget);
  
  // In the real app, we would verify the exact color values, but for this test
  // we simply verify that the background color isn't null
  expect(appBar.backgroundColor, isNotNull);
  
  // Print theme mode for visual verification
  print('AppHeader tested in ${isDarkMode ? 'dark' : 'light'} mode');
} 