import 'package:flutter/material.dart';



Color primaryLight = const Color(0xFFFFFFFF);
Color primaryDark = const Color(0xff1A1A1A); // Tối hơn để tương phản với text
Color inverseLight = const Color(0xff121212); // Tối hơn cho text trên nền sáng
Color inverseDark = const Color(0xffF5F5F5); // Sáng hơn cho text trên nền tối
Color surfaceLight = const Color(0xFFFAFAFA); // Trắng gần như thuần khiết
Color surfaceDark = const Color(0xFF121212); // Đen chuẩn Material Design
Color borderLight = const Color(0xffBDBDBD); // Đậm hơn để nhìn rõ
Color borderDark = const Color(0xff424242); // Sáng hơn để tương phản với nền tối
Color highlightColorLight = const Color(0xff2196F3); // Material Blue
Color highlightColorDark = const Color(0xff64B5F6); // Sáng hơn cho dark mode

// Thêm màu phụ trợ cho charts và UI
Color successLight = const Color(0xff4CAF50);
Color successDark = const Color(0xff66BB6A);
Color warningLight = const Color(0xffFF9800);
Color warningDark = const Color(0xffFFB74D);
Color errorLight = const Color(0xffF44336);
Color errorDark = const Color(0xffEF5350);
Color infoLight = const Color(0xff2196F3);
Color infoDark = const Color(0xff64B5F6);
Color yellowLight = const Color(0xffFFEB3B);
Color yellowDark = const Color(0xffFFF176);

// Extension để truy cập màu semantic dễ dàng
extension ColorSchemeExtension on ColorScheme {
  Color get success => brightness == Brightness.light ? successLight : successDark;
  Color get warning => brightness == Brightness.light ? warningLight : warningDark;
  Color get info => brightness == Brightness.light ? infoLight : infoDark;
  Color get yellow => brightness == Brightness.light ? yellowLight : yellowDark;
}


const TextStyle normalText = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.normal,
);

const TextStyle titleText = TextStyle(
  fontSize: 23,
  fontWeight: FontWeight.w600,
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  fontFamily: 'Ubuntu',
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: surfaceLight,
    primary: primaryLight,
    outline: borderLight,
    primaryContainer: highlightColorLight,
    inversePrimary: inverseLight,
    // Thêm màu semantic
    error: errorLight,
    onError: Colors.white,
    // Cải thiện contrast cho text
    onSurface: const Color(0xff0D0D0D), // Đen đậm cho text chính
    onPrimary: const Color(0xff0D0D0D), // Đen đậm cho text trên nền primary
    onSecondary: Colors.white, // Trắng cho text trên nền secondary
    onTertiary: Colors.white, // Trắng cho text trên nền tertiary
    // Thêm màu phụ cho charts
    secondary: successLight,
    tertiary: warningLight,
    secondaryContainer: successLight.withOpacity(0.1),
    tertiaryContainer: warningLight.withOpacity(0.1),
  ),
  // Cải thiện input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderLight, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderLight, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: highlightColorLight, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: errorLight, width: 1.5),
    ),
    labelStyle: TextStyle(color: const Color(0xff212121)), // Đậm hơn cho light mode
    hintStyle: TextStyle(color: const Color(0xff424242)), // Đậm hơn cho light mode
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  // Cải thiện elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: highlightColorLight,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Ubuntu',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  // Cải thiện card theme cho biểu đồ
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    surfaceTintColor: Colors.transparent, // Loại bỏ tint color
  ),
  // Cải thiện app bar theme
  appBarTheme: AppBarTheme(
    elevation: 1,
    backgroundColor: primaryLight,
    foregroundColor: inverseLight,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Color(0xff0D0D0D), // Text đen đậm cho app bar
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Ubuntu',
    ),
  ),
  // Cải thiện text theme cho light mode
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w500),
    titleSmall: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.normal),
    bodySmall: TextStyle(color: Color(0xff212121), fontWeight: FontWeight.normal), // Đậm hơn để nhìn rõ
    labelLarge: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w500),
    labelMedium: TextStyle(color: Color(0xff0D0D0D), fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: Color(0xff212121), fontWeight: FontWeight.w500), // Đậm hơn để nhìn rõ
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  fontFamily: 'Ubuntu',
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: surfaceDark,
    primary: primaryDark,
    outline: borderDark,
    primaryContainer: highlightColorDark,
    inversePrimary: inverseDark,
    // Thêm màu semantic
    error: errorDark,
    onError: Colors.black,
    // Cải thiện contrast cho dark mode
    onSurface: const Color(0xffF5F5F5), // Trắng sáng cho text chính
    onPrimary: const Color(0xffF5F5F5), // Trắng sáng cho text trên nền primary
    onSecondary: Colors.black, // Đen cho text trên nền secondary
    onTertiary: Colors.black, // Đen cho text trên nền tertiary
    // Thêm màu phụ cho charts
    secondary: successDark,
    tertiary: warningDark,
    secondaryContainer: successDark.withOpacity(0.2), // Tăng opacity để thấy rõ hơn
    tertiaryContainer: warningDark.withOpacity(0.2),
  ),
  // Cải thiện input decoration theme cho dark mode
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xff2D2D2D),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderDark, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderDark, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: highlightColorDark, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: errorDark, width: 1.5),
    ),
    labelStyle: TextStyle(color: const Color(0xffE0E0E0)), // Sáng hơn cho dark mode
    hintStyle: TextStyle(color: const Color(0xffBDBDBD)), // Sáng hơn cho dark mode
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  // Cải thiện elevated button theme cho dark mode
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: highlightColorDark,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Ubuntu',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  // Cải thiện card theme cho dark mode
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: const Color(0xff1E1E1E), // Màu card đậm hơn cho dark mode
    surfaceTintColor: Colors.transparent, // Loại bỏ tint color
  ),
  // Cải thiện app bar theme cho dark mode
  appBarTheme: AppBarTheme(
    elevation: 1,
    backgroundColor: primaryDark,
    foregroundColor: inverseDark,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Color(0xffF5F5F5), // Text trắng sáng cho app bar
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Ubuntu',
    ),
  ),
  // Cải thiện text theme cho dark mode
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w500),
    titleSmall: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.normal),
    bodySmall: TextStyle(color: Color(0xffE0E0E0), fontWeight: FontWeight.normal), // Sáng hơn để nhìn rõ
    labelLarge: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w500),
    labelMedium: TextStyle(color: Color(0xffF5F5F5), fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: Color(0xffE0E0E0), fontWeight: FontWeight.w500), // Sáng hơn để nhìn rõ
  ),
);