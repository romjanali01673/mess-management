
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/bazer_provider.dart';
import 'package:mess_management/providers/deposit_provider.dart';
import 'package:mess_management/providers/firstScreen_provider.dart';
import 'package:mess_management/providers/fund_provider.dart';
import 'package:mess_management/providers/meal_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/providers/notice_provider.dart';
import 'package:mess_management/setting/change_email.dart';
import 'package:mess_management/setting/change_password.dart';
import 'package:mess_management/setting/edit_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {











Future<void> logoutAndReset(BuildContext context) async {
  try {

    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();
    await authProvider.setDeviceToken(null);

    // Firebase logout
    await FirebaseAuth.instance.signOut();

    // Try to clear cache
    try {
      await Future.delayed(Duration(milliseconds: 500));
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      debugPrint("Firestore clearPersistence() failed: $e");
    }

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset provider state (if you have reset methods)
    Provider.of<AuthenticationProvider>(context, listen: false).reset();
    Provider.of<MessProvider>(context, listen: false).reset();
    Provider.of<BazerProvider>(context, listen: false).reset();
    Provider.of<DepositProvider>(context, listen: false).reset();
    Provider.of<FundProvider>(context, listen: false).reset();
    Provider.of<MealProvider>(context, listen: false).reset();
    Provider.of<NoticeProvider>(context, listen: false).reset();
    Provider.of<FirstScreenProvider>(context, listen: false).reset();

    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.LandingScreen, // or your login screen
      (route) => false,
    );
  } catch (e) {
    showSnackber(context: context, content: "Logout Failed\n${e.toString()}");
    debugPrint(e.toString());
  }
}

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      
        body : Container(
          color: Colors.grey,
          height: double.infinity,
          width: double.infinity,
          child: ListView(
            children: [
              getItem(label: "Edit Profile", icon: Icons.supervised_user_circle_rounded, ontap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>EditInfo()));} ),
              getItem(label: "Change Email", icon: Icons.edit, ontap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeEmail()));} ),
              getItem(label: "Change Password", icon: Icons.lock, ontap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangePassword()));}),
              getItem(
                label: "Logout", 
                icon: Icons.logout, 
                ontap: () async{
                  bool? res = await showConfirmDialog(context: context, title: "Do you want to Logout?");
                  if(res??false){
                    // clear all cash and navigate  to login screen.
                    logoutAndReset(context);
                  }
                },
              ),
            ],
          ),
        ),
    );
  }
}

Widget getItems({required String label, required IconData icon, Function()? ontap ,required bool selected}) {
  return GestureDetector(
    onTap: ontap ?? () {},
    child: Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(  // 💡 Let the whole row use max width if needed
            child: Row(
              children: [
                Icon(icon, size: 25),
                SizedBox(width: 8),
                Expanded(  // 💡 This makes text wrap or ellipsis
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis, // or .fade or .clip
                  ),
                ),
              ],
            ),
          ),
          selected ? Icon(Icons.ads_click, size: 20) : SizedBox.shrink(),
        ],
      ),
    ),
  );
}


Widget getItem({required String label, required IconData icon, Function()? ontap }){
  return GestureDetector(
    onTap: ontap??(){},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                Text(label)
              ]
            ),
          ),
        ),
      ),
  );
}









// "editor.codeActionsOnSave": {
//   "source.fixAll": true
// }

