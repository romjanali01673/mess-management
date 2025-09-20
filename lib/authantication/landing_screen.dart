
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/services/asset_manager.dart';
import 'package:mess_management/services/fmc_server_key.dart';
import 'package:mess_management/services/notification_services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  @override
  void initState() {
    // TODO: implement initState
    checkAuthenticationState();
    super.initState();
  }

  void checkAuthenticationState()async{
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    if(! await authProvider.checkIsSubcscraiber()){
      showMessageDialog(context: context, title: "Requred Subscreption!", Discreption: "Contact With \'engromjanali@gmail.com\'");
      return;
    }
    if(await authProvider.checkIsSignedIn()){
      try{
        // get user data from fireStore
        print("Aaaaaaaaaaaaaaaaaaaaaaa");
        await authProvider.getUidFromFiretore(
          onFail: (message){
          if(mounted) showSnackber(context: context, content: "somthing Wrong\n uid fatch error\n$message");
          navigate(isSignedIn: false);
        });
        debugPrint("getUserProfileData");
        await authProvider.getUserProfileData(onFail: (message) {  
          if(mounted) showSnackber(context: context, content: message.toString());
          navigate(isSignedIn: false);
        });
        debugPrint("sessionValid");
        await authProvider.sessionValid(
          onSuccess:(res)async{
            if(res){
                // set user data to shared preference
              print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
              await authProvider.saveUserDataToSharedPref();

              //navigate to home screen
              // await Future.delayed(Duration(seconds: 5));
              print("ccccccccccccccccccccccccccccc");
              print(authProvider.getUserModel!.toMap());
              navigate(isSignedIn: true);

              await messProvider.getMessData(onFail: (_){}, messId: authProvider.getUserModel!.currentMessId);
            }
            else{
              // perform an opration from here for clear cache 

              // Navigate to sigin screen
              if(mounted) showSnackber(context: context, content: "Invalid Session");
              navigate(isSignedIn: false);
            }
          },
          onFail: (message){
            if(mounted) showSnackber(context: context, content: "Somthing Wrong\n$message"+"001");
            // Navigate to sigin screen
            navigate(isSignedIn: false);
          }
        );



      }catch(e){
        print("xyz@${e.toString()}");
        if(mounted) showSnackber(context: context, content: e.toString());
      }
    }
    else{
      // Navigate to sigin screen
      navigate(isSignedIn: false);
    }
  }

  void navigate({required bool isSignedIn}){
    if(isSignedIn){
      // remove all previous page 
      // and navigate to home screen
      Navigator.pushNamedAndRemoveUntil(context, Constants.HomeScreen,(route)=>false);
    }
    else{
      // remove all previous page 
      // and navigate to login screen
      Navigator.pushNamedAndRemoveUntil(context, Constants.logInScreen,(route)=>false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 120,
                backgroundColor: Colors.black45,
                backgroundImage: AssetImage(AssetsManager.splashLogo),
              ),
            ),
            Text("Loading....")
          ],
        ),
      ),
    );
  }


}
