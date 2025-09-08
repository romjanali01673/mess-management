import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MessCloseScreen extends StatefulWidget {
  const MessCloseScreen({super.key});

  @override
  State<MessCloseScreen> createState() => _MessCloseScreenState();
}

class _MessCloseScreenState extends State<MessCloseScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_)async{
      if(Platform.isIOS){
        await Future.delayed(Duration(seconds: 1));
        // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          // statusBarIconBrightness: Brightness.light,// icon color
          // statusBarColor: Colors.black,
          // statusBarBrightness: Brightness.light,//IOs dark->white, light->black(default), it's a transparent statusbar, so we can't change status-bar,navigatation-bar color. 
       
          // systemNavigationBarColor: Colors.black,
          // systemNavigationBarIconBrightness: Brightness.light,
          // systemNavigationBarDividerColor: Colors.grey,

        // ));
      }
      else{
        // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        //   statusBarIconBrightness: Brightness.light,// icon color
        //   statusBarColor: Colors.black,
        //   statusBarBrightness: Brightness.light,//IOs dark->white, light->black(default), it's a transparent statusbar, so we can't change status-bar,navigatation-bar color. 
        // ));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // final colseMessHisabProvider = context.read<ColseMessHisabProvider>();
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    print(MediaQuery.of(context).padding);
      return Scaffold(
        backgroundColor: Colors.green.shade100,
        // appBar: AppBar(
        //   title: Text("Close Meal Hisab"),
        //   backgroundColor: Colors.grey,
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height:Platform.isIOS? 40:10,
              ),
              SizedBox(
                height: 400,
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: ()async{
                      if(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider)){
                        bool confirm = await  showConfirmDialog(context: context,title: "Close Meal Session (Must Read)", subTitle: "Form now you are. going to create a new meal session and close this session.\n\nNote: You will loss \"edit\" access for this data after close this Meal Session.");
                        if(confirm){
                          messProvider.closeMessHisab(
                            messId: authProvider.getUserModel!.currentMessId,
                            onFail: (message){
                              showSnackber(context: context, content: "Failed\n$message");
                            },
                            onSuccess: (){
                              showSnackber(context: context, content: "Successed");
                            }
                          );
                        }
                      }
                      else{
                        showSnackber(context: context, content: "required Administrator power");
                      }
                    }, 
                    child: Text("close"),
                  ),
              ),
            ],
          ),
        ),
      );
    // );  
    }
}