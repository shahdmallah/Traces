import 'package:flutter/material.dart';

class AppColors {
  // ============= NATURE-INSPIRED PALETTE (From your CSS) =============
  
  // Background & Surface Colors
  static const background = Color(0xFFFAF8F5);  // Warm off-white
  static const foreground = Color(0xFF2C3A2F);  // Deep forest green
  static const card = Color(0xFFFFFFFF);        // Pure white
  static const cardForeground = Color(0xFF2C3A2F);
  
  // Primary & Secondary
  static const primary = Color(0xFF5F7A61);     // Olive green
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFF5F1E8);   // Warm cream
  static const secondaryForeground = Color(0xFF2C3A2F);
  
  // Muted & Accent
  static const muted = Color(0xFFE8E3D6);       // Soft sand
  static const mutedForeground = Color(0xFF6B7565);
  static const accent = Color(0xFF8B9D83);      // Sage green
  static const accentForeground = Color(0xFFFFFFFF);
  
  // Status Colors
  static const destructive = Color(0xFFB85C50);  // Warm terracotta red
  static const destructiveForeground = Color(0xFFFFFFFF);
  
  // UI Element Colors
  static const border = Color(0x1E5F7A61);       // Primary with 12% opacity
  static const inputBackground = Color(0xFFF5F1E8);
  static const switchBackground = Color(0xFFD4CFC0);
  
  // Nature-inspired extras
  static const olive = Color(0xFF5F7A61);
  static const sage = Color(0xFF8B9D83);
  static const forest = Color(0xFF4A5F4C);
  static const sand = Color(0xFFD4CFC0);
  static const earth = Color(0xFFA68968);
  static const sky = Color(0xFF7B9FAD);
  static const stone = Color(0xFF9C9486);

  // Additional palette colors
  static const cream = Color(0xFFE9E3DB);
  static const beige = Color(0xFFF0E7D9);
  static const taupe = Color(0xFFB8A78F);
  static const deepForest = Color(0xFF191F18);

  // Status colors (semantic)
  static const success = Color(0xFF4A5F4C);     // Forest green
  static const warning = Color(0xFFA68968);     // Earth
  static const error = Color(0xFFB03A33);       // Reddish

  // Backwards compatibility (from old theme)
  static const indigoRain = Color(0xFF191F18);  // Deep forest
  static final overlayDark = Colors.black.withValues(alpha: 0.35);

  // Dark mode colors
  static const darkBackground = Color(0xFF252525);
  static const darkForeground = Color(0xFFF5F5F5);
  static const darkCard = Color(0xFF252525);
  static const darkBorder = Color(0xFF444444);
}

class AppTextStyles {
  // Font configuration matching your CSS
  static const String fontFamily = 'Inter';
  static const String fontFamilyHeading = 'Poppins';
  
  // Heading styles
  static const heading1 = TextStyle(
    fontSize: 24,  // text-2xl = 24px
    fontWeight: FontWeight.w500,  // --font-weight-medium
    height: 1.5,
    fontFamily: fontFamilyHeading,
    letterSpacing: -0.3,
  );
  
  static const heading2 = TextStyle(
    fontSize: 20,  // text-xl = 20px
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamilyHeading,
    letterSpacing: -0.2,
  );
  
  static const heading3 = TextStyle(
    fontSize: 18,  // text-lg = 18px
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamilyHeading,
  );
  
  static const heading4 = TextStyle(
    fontSize: 16,  // text-base = 16px
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamilyHeading,
  );
  
  // Body text
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: fontFamily,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: fontFamily,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: fontFamily,
  );
  
  // Labels
  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamily,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamily,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamily,
  );
  
  // Button text
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamily,
    letterSpacing: 0.3,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      surface: AppColors.background,
      onSurface: AppColors.foreground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      tertiary: AppColors.accent,
      onTertiary: AppColors.accentForeground,
    ),
    
    // Typography
    fontFamily: AppTextStyles.fontFamily,
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      displaySmall: AppTextStyles.heading3,
      headlineLarge: AppTextStyles.heading2,
      headlineMedium: AppTextStyles.heading3,
      headlineSmall: AppTextStyles.heading4,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.background,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.heading3,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // --radius: 1.25rem
        side: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
    ),
    
    // Input Decoration (matching your CSS)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),  // Slightly smaller than card radius
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.destructive, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedForeground),
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.foreground),
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    
    // Switches (matching your --switch-background)
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.switchBackground;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.switchBackground;
      }),
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.muted,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.foreground),
      secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryForeground),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
    
    // Radius
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkForeground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      tertiary: AppColors.accent,
      onTertiary: AppColors.accentForeground,
    ),
    
    fontFamily: AppTextStyles.fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.heading1.copyWith(color: AppColors.darkForeground),
      displayMedium: AppTextStyles.heading2.copyWith(color: AppColors.darkForeground),
      displaySmall: AppTextStyles.heading3.copyWith(color: AppColors.darkForeground),
      headlineLarge: AppTextStyles.heading2.copyWith(color: AppColors.darkForeground),
      headlineMedium: AppTextStyles.heading3.copyWith(color: AppColors.darkForeground),
      headlineSmall: AppTextStyles.heading4.copyWith(color: AppColors.darkForeground),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkForeground),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkForeground),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkForeground.withValues(alpha: 0.7)),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.darkForeground),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.darkForeground),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.darkForeground.withValues(alpha: 0.7)),
    ),
    
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkForeground,
      surfaceTintColor: Colors.transparent,
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedForeground),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}