import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/helper/ui_helper.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;


  void openAppSettings()async {
    
    if(Platform.isAndroid){
      await AppSettings.openAppSettings(
        type: AppSettingsType.notification, // android navigate to notification permision page.
        asAnotherTask: true,
      );
    }

    
    // reopen to check has permision or not.
    
  }

  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, // show notificition on display 
      announcement: true, // siri can't read for false,
      badge:  true, // to show index
      carPlay: true, // 
      criticalAlert: true,
      // provisional: true, //Note that on iOS, if [provisional] is set to true, silent notification permissions will be automatically granted. When notifications are delivered to the device, the user will be presented with an option to disable notifications, keep receiving them silently or enable prominent notifications.
      sound: true,
      providesAppNotificationSettings: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      debugPrint("user authorized: Android");
    }
    else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      debugPrint("user Provisional: IOS");
    }
    else{
      debugPrint("user denaided");
      openAppSettings();
    }
  }

  // for ios semolator we have to 
  Future<String> getDeviceToken(Function(String) onFail)async{
    String? deviceToken;
    try {
      deviceToken =  await messaging.getToken();
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
    return deviceToken??"";
  }



}