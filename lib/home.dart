import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/bazer/bazer_screen.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/diposite/diposite.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/setting/edit_info.dart';
import 'package:meal_hisab/fand/fand.dart';
import 'package:meal_hisab/meal/meal.dart';
import 'package:meal_hisab/member/member_screen.dart';
import 'package:meal_hisab/mess/mess_screen.dart';
import 'package:meal_hisab/notice_and_announcement.dart';
import 'package:meal_hisab/setting/setting_secrren.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DrawerItem DrawerItemGroup = DrawerItem.Home;

  bool visibleCurrent = false;
  bool visibleNew = false;
  bool visibleConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        
        actions: [
          
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.notifications),
          ),
          SizedBox(width: 10,),
        ],
        
      ),
      drawer: Drawer(
        child: ListView(
          children:[
            UserAccountsDrawerHeader(
              
              accountName: Text('Md Romjan Ali', textAlign: TextAlign.center,style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal),),
              accountEmail: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  children: [
                    TextSpan(text: "Id No : "),
                    TextSpan(text: "10203040"),
                    TextSpan(text: "  "),
                    TextSpan(text: "(Member)"),

                  ]
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blue,
                backgroundImage: NetworkImage(
                  'https://media.licdn.com/dms/image/v2/D5603AQHLNWai9JVADg/profile-displayphoto-shrink_800_800/B56ZabNxZLGkAc-/0/1746360801482?e=1752105600&v=beta&t=LQU-OyXoCMujQ7QcE7WOjy3JqqurI-BwlDIgshNtmOQ', // Replace with your image URL or Asset
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
            ),
           
            getItems(
              icon: Icons.home, 
              label: "Home",
              selected: DrawerItemGroup==DrawerItem.Home, 
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup = DrawerItem.Home;
                setState(() {
                
                });
              },
            ),
            getItems(
              icon: FontAwesomeIcons.a, 
              label: "Meal",
              selected: DrawerItemGroup==DrawerItem.Meal,
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup = DrawerItem.Meal;
                setState(() {
                
                });
              },
            ),
            getItems(
              icon: FontAwesomeIcons.peopleGroup, 
              label: "Members",
              selected: DrawerItemGroup==DrawerItem.Members,
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup=DrawerItem.Members;
                setState(() {
                
                });
              },
            ),
            getItems(icon: Icons.assessment, 
              label: "Fand",
              selected: DrawerItemGroup==DrawerItem.Fand, 
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup=DrawerItem.Fand;
                setState(() {
                
                });
              },
            ),
            getItems(icon: Icons.assessment, 
              label: "Diposite",
              selected: DrawerItemGroup==DrawerItem.Diposite, 
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup=DrawerItem.Diposite;
                setState(() {
                
                });
              },
            ),
            getItems(
              icon: Icons.announcement, 
              label: "Notice & Announcements",
              selected: DrawerItemGroup ==DrawerItem.Notice_And_Announcements,
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup =DrawerItem.Notice_And_Announcements;
                setState(() {
                
                });
              },
            ),
            getItems(
              icon: Icons.payment, 
              label: "Bazer",
              selected: DrawerItemGroup == DrawerItem.Bazer,
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup=DrawerItem.Bazer;
                setState(() {
                
                });
              },
            ),
            getItems(
              icon: Icons.other_houses_sharp, 
              label: "Mess",
              selected: DrawerItemGroup == DrawerItem.Mess,
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup=DrawerItem.Mess;
                setState(() {
                
                });
              },
            ),
            getItems(
              icon: Icons.settings, 
              label: "Settings",
              selected: DrawerItemGroup ==DrawerItem.Settings,
              ontap: () {
                Navigator.pop(context);
                DrawerItemGroup = DrawerItem.Settings;
                setState(() {
                
                });
              },
            ),
          ],
        ),
      ),
      
      body:
      DrawerItemGroup == DrawerItem.Meal ? MealScreen()
      :
      DrawerItemGroup == DrawerItem.Members ? MemberScreen()
      :
      DrawerItemGroup == DrawerItem.Fand ? FandScreen()
      :
      DrawerItemGroup == DrawerItem.Notice_And_Announcements ? NoticeAndAnnouncementScreen()
      :
      DrawerItemGroup == DrawerItem.Bazer ? BazerScreen()
      :
      DrawerItemGroup == DrawerItem.Settings ? SettingScreen()
      :
      DrawerItemGroup == DrawerItem.Diposite ? DipositeScreen()
      :
      DrawerItemGroup == DrawerItem.Mess ? MessScreen()
      :
      Container(  // home Screen
        height: double.infinity,
        width: double.infinity,
        color: Colors.black,
      )

    );
  }
}



