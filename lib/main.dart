import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_constants.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const JewelleryTryOnApp());
}

class JewelleryTryOnApp extends StatelessWidget {
  const JewelleryTryOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jewellery TryOn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.goldColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Body text: Lato (clean & readable)
        textTheme: GoogleFonts.latoTextTheme(),
        // Override display/title to Playfair Display (elegant serif)
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
