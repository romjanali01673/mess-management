import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_management/bazer/bazer_screen.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/deposit/deposit.dart';
import 'package:mess_management/fund/fund.dart';
import 'package:mess_management/first_screen.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/meal/meal.dart';
import 'package:mess_management/member/member_screen.dart';
import 'package:mess_management/mess/mess_screen.dart';
import 'package:mess_management/notice_and_announcement.dart';
import 'package:mess_management/pre_data/pre_data.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/providers/notice_provider.dart';
import 'package:mess_management/services/notification_services.dart';
import 'package:mess_management/setting/setting_secrren.dart';
import 'package:provider/provider.dart';

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
  void initState(){
    super.initState();
    
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    checkNotification();

    if(authProvider.getUserModel!.currentMessId == ""){

    } 
    else{
      messProvider.getMessData(
        messId: authProvider.getUserModel!.currentMessId,
        onFail: (_){
        }, 
        onSuccess: () {
          setState(() {
            
          });
        },
      );
    }
  }

  void checkNotification()async{
    
    await Future.delayed(Duration(milliseconds: 50));
    
    final authProvider = context.read<AuthenticationProvider>();
    final noticeProvider = context.read<NoticeProvider>();

    noticeProvider.checkHasNoticeUnseen(uid: authProvider.getUserModel!.uId, messId: authProvider.getUserModel!.currentMessId, mealSessionId: authProvider.getUserModel!.mealSessionId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(messProvider.getMessModel?.messName?? "Mess Name"),
        
        actions: [
          
          Consumer<NoticeProvider>(
            child: SizedBox.shrink(),
            // here declear a child and it will be pass as the given bilew "widget" as Widget.
            // we can use the "widget" under the builder. check in last. 
            // we have use it under the children of stack 
            builder: (context, noticeProvider, widget) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.black,size: 35,),
                    onPressed: () {
                      // Go to notifications page
                      // Optional: mark notifications seen
                      // setState(() {
                      //   DrawerItemGroup=DrawerItem.Notice_And_Announcements;
                      // });
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>NoticeAndAnnouncementScreen()));
                    },
                  ),
                  if (noticeProvider.getHasUnseen)Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
                  // in here in using widget 
                  // the widget will not rebuild when we 
                  widget!
                ]
              );
            }
          ),
          GestureDetector(
            onTap: (){
              showSnackber(context: context, content: "Currently Unavailable");
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>OptimizedNestedSliverList()));
            },
            child: FaIcon(FontAwesomeIcons.facebookMessenger,color: Colors.black,size: 35,)),
          SizedBox(
            width: 5,
          )
        ],
      ),
      
      drawer: Drawer(
        child: ListView(
          children:
          authProvider.getUserModel == null?
          [
            Center(child: Text("User Not Found"),),
          ]
          :
          [
            UserAccountsDrawerHeader(
              
              otherAccountsPictures:[
                IconButton(
                  onPressed: (){
                    Clipboard.setData(ClipboardData(text: authProvider.getUserModel?.uId.toString()??""));
                    Navigator.of(context).pop();
                    showSnackber(context: context, content: 'Copyed!');
                  }, 
                  icon: Icon(Icons.copy)
                )
              ],
              accountName: Text(capitalizeEachWord(authProvider.getUserModel!.fname.toString()), textAlign: TextAlign.center,style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal),),
              accountEmail: SelectableText.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    // fontStyle: FontStyle.italic,
                    overflow: TextOverflow.ellipsis
                  ),
                  children: [
                    TextSpan(text: "ID: "),
                    TextSpan(text: capitalizeEachWord(authProvider.getUserModel!.uId.toString())),
                    TextSpan(text: "  "),
                    amIAdmin(messProvider: messProvider, authProvider: authProvider) ? TextSpan(text: "(${Constants.menager})")
                    :
                    amIactmenager(messProvider: messProvider, authProvider: authProvider)? TextSpan(text:"(${Constants.actMenager})" )
                    :
                    TextSpan(text: "(${Constants.member})", style: TextStyle(fontSize: 14)),
              
              
                  ]
                ),
              ),
              currentAccountPictureSize:Size.square(60),
              currentAccountPicture: CircleAvatar(
                
                backgroundColor: Colors.blue,
                // backgroundImage: NetworkImage(
                //   "https://scontent.fdac80-1.fna.fbcdn.net/v/t39.30808-6/490295869_1342466350336950_1132803492906371083_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeHIbKvKiEjuSiifxz4S-T6tNVr7432uvrU1Wvvjfa6-tbMkCjKUjhLieukD-hKVHQVy_HFqvTb9rPwSGiAuSoHV&_nc_ohc=Otwk__7-HVAQ7kNvwGvWAAK&_nc_oc=AdnRGR44kqFf_okZBdFDtCo469hJ9y1JncDNOkfuEhLo-3Yg2rKq0U7dfujLTPo8KZw&_nc_zt=23&_nc_ht=scontent.fdac80-1.fna&_nc_gid=OfKQKXnlSFdmuZM58inpWw&oh=00_AfP5G7Oin4ltgLTKmHkOb6oO-JJGH10FnlVTAE4teDP-Iw&oe=6858DE47"
                // ),
                child: Text("Paid"),
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
              icon: FontAwesomeIcons.m, 
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
            getItems(
              icon: FontAwesomeIcons.bangladeshiTakaSign, 
              label: "Fund",
              selected: DrawerItemGroup==DrawerItem.Fund, 
              ontap: () {
                // DrawerItemGroup=DrawerItem.Fund;
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FundScreen()),
                );
                setState((){

                });
              },
            ),
            getItems(icon: Icons.assessment, 
              label: "Deposit",
              selected: DrawerItemGroup==DrawerItem.Deposit, 
              ontap: () {
                // Navigator.pop(context);
                // DrawerItemGroup=DrawerItem.Deposit;
                // setState(() {
                
                // });
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>DepositScreen()));
              },
            ),
            getItems(
              icon: Icons.announcement, 
              label: "Notice & Announcements",
              selected: DrawerItemGroup ==DrawerItem.Notice_And_Announcements,
              ontap: () {
                Navigator.pop(context);
                // DrawerItemGroup =DrawerItem.Notice_And_Announcements;
                // setState(() {
                
                // });
                Navigator.push(context, MaterialPageRoute( builder:(context)=> NoticeAndAnnouncementScreen()));
              },
            ),
            getItems(
              icon: Icons.shopping_bag_outlined, 
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
                // DrawerItemGroup=DrawerItem.Mess;
                // setState(() {
                
                // });
                Navigator.push(context, MaterialPageRoute( builder:(context)=> MessScreen()));
              },
            ),
            getItems(
              icon: Icons.dataset_linked, 
              label: "Pre Data",
              selected: DrawerItemGroup == DrawerItem.PreData,
              ontap: () {
                Navigator.pop(context);
                // DrawerItemGroup=DrawerItem.Mess;
                // setState(() {
                
                // });
                Navigator.push(context, MaterialPageRoute( builder:(context)=> PreDataScreen()));
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
      DrawerItemGroup == DrawerItem.Fund ? FundScreen()
      :
      DrawerItemGroup == DrawerItem.Notice_And_Announcements ? NoticeAndAnnouncementScreen()
      :
      DrawerItemGroup == DrawerItem.Bazer ? BazerScreen()
      :
      DrawerItemGroup == DrawerItem.Settings ? SettingScreen()
      :
      DrawerItemGroup == DrawerItem.Deposit ? DepositScreen()
      :
      DrawerItemGroup == DrawerItem.Mess ? MessScreen()
      :
      FirstScreen(),
    );
  }
}



