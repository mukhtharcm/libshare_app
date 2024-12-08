import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/book_provider.dart';
import 'screens/book_list_screen.dart';

void main() {
  runApp(const LibShareApp());
}

class LibShareApp extends StatelessWidget {
  const LibShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookProvider(),
      child: MaterialApp(
        title: 'LibShare',
        theme: FlexThemeData.light(
          scheme: FlexScheme.indigo,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 7,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 10,
            blendOnColors: false,
            useTextTheme: true,
            useM2StyleDividerInM3: true,
            alignedDropdown: true,
            useInputDecoratorThemeInDialogs: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            inputDecoratorUnfocusedBorderIsColored: false,
            fabUseShape: true,
            fabAlwaysCircular: false,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
          textTheme: GoogleFonts.openSansTextTheme(),
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.indigo,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 13,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            useTextTheme: true,
            useM2StyleDividerInM3: true,
            alignedDropdown: true,
            useInputDecoratorThemeInDialogs: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            inputDecoratorUnfocusedBorderIsColored: false,
            fabUseShape: true,
            fabAlwaysCircular: false,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
          textTheme: GoogleFonts.openSansTextTheme(),
        ),
        themeMode: ThemeMode.system,
        home: const BookListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
