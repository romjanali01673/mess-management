import 'package:firebase_core/firebase_core.dart';
import 'package:mess_management/authantication/Sign_up.dart';
import 'package:mess_management/authantication/landing_screen.dart';
import 'package:mess_management/authantication/sign_in.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/firebase_options.dart';
import 'package:mess_management/home.dart';
import 'package:mess_management/tab_bar.dart';
import 'package:mess_management/test.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/bazer_provider.dart';
import 'package:mess_management/providers/deposit_provider.dart';
import 'package:mess_management/providers/fund_provider.dart';
import 'package:mess_management/providers/firstScreen_provider.dart';
import 'package:mess_management/providers/meal_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/providers/notice_provider.dart';
import 'package:mess_management/video_page.dart';

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
      // home:  TestScreen(),
      initialRoute: Constants.LandingScreen,
      // home: MyVideoUI(),
      routes: {  
        Constants.HomeScreen : (context) => const HomeScreen(),
        Constants.logInScreen:(context)=> const SignInScreen(),
        Constants.SignUpScreen:(context)=> const SignUpScreen(),
        Constants.LandingScreen:(context)=> const LandingScreen(),
        // Constants.mealSessionList:(context)=> const MessCloseScreen(),
      },
    );
  }
}

