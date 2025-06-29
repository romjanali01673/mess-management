import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/authantication/Sign_up.dart';
import 'package:meal_hisab/authantication/landing_screen.dart';
import 'package:meal_hisab/authantication/sign_in.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/firebase_options.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/bazer_provider.dart';
import 'package:meal_hisab/providers/colse_mess_hisab_provider.dart';
import 'package:meal_hisab/providers/deposit_provider.dart';
import 'package:meal_hisab/providers/fund_provider.dart';
import 'package:meal_hisab/providers/firstScreen_provider.dart';
import 'package:meal_hisab/providers/meal_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:meal_hisab/providers/notice_provider.dart';
import 'package:provider/provider.dart';

// void main() {
//   runApp(const MyApp());
// }

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // add all provider here
        ChangeNotifierProvider(create: (_) => ColseMessHisabProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => FirstScreenProvider()),
        ChangeNotifierProvider(create: (_) => FundProvider()),
        ChangeNotifierProvider(create: (_) => DepositProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => BazerProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => MessProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home:  HomeScreen(),
      initialRoute: Constants.LandingScreen,
      routes: {  
        Constants.HomeScreen : (context) => const HomeScreen(),
        Constants.logInScreen:(context)=> const SignInScreen(),
        Constants.SignUpScreen:(context)=> const SignUpScreen(),
        Constants.LandingScreen:(context)=> const LandingScreen(),
      },
    );
  }
}

