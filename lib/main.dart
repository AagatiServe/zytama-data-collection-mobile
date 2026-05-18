import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<ProductBloc>(create: (_) => di.sl<ProductBloc>()),
      ],
      child: MaterialApp(
        title: 'Field Collection',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0d631b),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.workSansTextTheme(),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 1,
            titleTextStyle: GoogleFonts.workSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF071e27),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
