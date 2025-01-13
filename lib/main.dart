import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';

import 'blocs/book_list_bloc.dart' as book_list_bloc;
import 'blocs/category_bloc.dart' as category_bloc;
import 'database/database.dart';
import 'screens/book_list_screen.dart';

final getIt = GetIt.instance;

void main() {
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  runApp(const LibShareApp());
}

class LibShareApp extends StatelessWidget {
  const LibShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              book_list_bloc.BookListBloc(database: getIt<AppDatabase>())
                ..add(book_list_bloc.LoadBooks()),
        ),
        BlocProvider(
          create: (context) =>
              category_bloc.CategoryBloc(database: getIt<AppDatabase>())
                ..add(category_bloc.LoadCategories()),
        ),
      ],
      child: MaterialApp(
        title: 'LibShare',
        // Light Theme Configuration
        theme: FlexThemeData.light(
          scheme: FlexScheme.deepBlue, // Use Material 3 indigo scheme
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 7, // Adjust blend level for light theme
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 10,
            blendOnColors: false,
            // useTextTheme: true,
            useMaterial3Typography: true,
            useM2StyleDividerInM3: true,
            alignedDropdown: true, // Align dropdown items properly
            useInputDecoratorThemeInDialogs: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            inputDecoratorUnfocusedBorderIsColored: false,
            fabUseShape: true, // Use custom shape for FAB
            fabAlwaysCircular: false, // Allow non-circular FAB shapes
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true, // Enable Material 3
          swapLegacyOnMaterial3: true, // Swap legacy Material 2 defaults
          textTheme: GoogleFonts.ralewayTextTheme(), // Use Poppins font
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        // Dark Theme Configuration
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.indigo, // Use Material 3 indigo scheme
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 13, // Adjust blend level for dark theme
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            // useTextTheme: true,
            useMaterial3Typography: true,
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
          textTheme: GoogleFonts.poppinsTextTheme(), // Use Poppins font
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        themeMode: ThemeMode.system, // Follow system theme mode
        home: const BookListScreen(),
        debugShowCheckedModeBanner: false, // Remove debug banner
      ),
    );
  }
}
