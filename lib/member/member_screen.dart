import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/member/add_member.dart';
import 'package:meal_hisab/model/user_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  bool _isDisposed = false;

  Member memberScreemItemGrpup = Member.members;
  bool showScreen = false;
  Widget otherWiseScreen = Text("Loading...");
  @override
  void initState(){
    super.initState();
    final messProvaider = context.read<MessProvaider>();
    final authProvaider = context.read<AuthenticationProvider>();
    if(authProvaider.getUserModel!.currentMessId == ""){
      setState(() {
        otherWiseScreen =  Text("You are not connected to any mess.");
        showScreen = false;
      });
    } 
    else{
      messProvaider.getMessData(
        messId: authProvaider.getUserModel!.currentMessId,
        onFail: (message){
          setState(() {
            showScreen = false;
            showSnackber(context: context, content: "Mess Data Did Not Found\n$message");
            otherWiseScreen =  Text("Somthing Wrong\n try again");
          });
        }, 
        onSuccess: () {
          setState(() {
            showScreen = true;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isDisposed = true;
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return showScreen? Scaffold(
      body: Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
          
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 10,
                  children: [
                    getMenuItems(
                      label: "Members", 
                      ontap: (){
                        setState(() {
                          memberScreemItemGrpup = Member.members;
                        });
                      },
                      selected: memberScreemItemGrpup==Member.members,
                      icon: Icons.group
                    ),
                    getMenuItems(
                      label: "Add Member", 
                      ontap: (){
                        setState(() {
                          memberScreemItemGrpup = Member.AddMember;
                          
                        });
                      },
                      selected: memberScreemItemGrpup==Member.AddMember,
                      icon: (Icons.add_circle_outline_outlined),
                    ),
                  ],
                ),
              ),
              
              memberScreemItemGrpup==Member.members? getListOfMember()
              :
              AddMemberScreen()

            ],
          ),
        ),
      ),
    )
    :
    Scaffold(body: Center(child: otherWiseScreen!));
  }



  Widget getListOfMember(){

    final messProvaider = context.read<MessProvaider>();
    // final messProvaider = context.watch<MessProvaider>();
    final authProvaider = context.watch<AuthenticationProvider>();
    return Expanded(
      child: FutureBuilder(
        future:messProvaider.getMessData(
          onFail: (message) { 
            showSnackber(context: context, content: message);
          },
          messId: authProvaider.getUserModel!.currentMessId,
          isDisposed: ()=> _isDisposed,
          onSuccess: (){
            debugPrint("get mess data success");
            StatefulBuilder;
          },
        ),
        builder:(context, AsyncSnapshot snapshot) { 
          if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's save 
            return Center(child: CircularProgressIndicator());
          }
          
          else if (messProvaider.getMessModel==null ||messProvaider.getMessModel!.messMemberList.isEmpty ) {
            return Center(child: Text('No member found.'));
          }
          else{
            List<Map<String,dynamic>> data = messProvaider.getMessModel!.messMemberList;
            return StatefulBuilder(
              builder: (context, setLocalState) { 

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  Map<String,dynamic> memberData = data[index];
                  String memberType = 
                    messProvaider.getMessModel!.messAuthorityId==memberData[Constants.uId]? 
                      Constants.menager
                      : messProvaider.getMessModel!.messAuthorityId2nd==memberData[Constants.uId]? 
                      Constants.actMenager : Constants.member;
              
                  return  Card(
              
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 10),
                    leading: CircleAvatar(
                      child: Text(index.toString()),
                      backgroundColor: memberType==Constants.member? Colors.amber :Colors.red,
                    ),
                    title: Text(memberData[Constants.fname]),
                    subtitle: Text("${memberData[Constants.uId]}   ($memberType)"),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) {  
                        return [
                            PopupMenuItem(
                              onTap: ()async{
                                await messProvaider.change2ndMessOwnership(
                                  secondAdimnName: memberData[Constants.fname], 
                                  secondAdminId: memberData[Constants.uId], 
                                  onFail: (message){
                                      showSnackber(context: context, content: "Failed! Try again.\n$message");
                                  },
                                  onSuccess: (){
                                    // if (context.mounted) {
                                      showSnackber(context: context, content: "The member has been made Act  Meal Manager");
                                    // }
                                  },
                                );
                              },
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.transfer_within_a_station_sharp),
                                  Text("make Act Menager"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              onTap: ()async{
                                bool? a = await showConfirmDialog(context: context, title: "Do You Want to Transfer The Ownership?");
                                if(a??false){
                                  debugPrint("YES--------------");
                                  // remove from mess
                                  await messProvaider.kickMemberFromMess(member: memberData);
                                }
                                else{
                                  debugPrint("NO--------------");
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.highlight_remove_outlined),
                                  Text("kick"),
                                ],
                              ),
                            ),
              
                            memberData[Constants.status]==Constants.enable?
                            PopupMenuItem(
                              value: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.do_not_disturb_alt_outlined),
                                  Text("disable"),
                                ],
                              ),
                              onTap: ()async{
                                // change member status
                                memberData[Constants.status] = Constants.disable;
                                final list = messProvaider.getMessModel!.messMemberList;
                                list[index] = memberData;
                                messProvaider.setMessModel(messMemberList: list);
                                await messProvaider.changeMemberStatus();
                                
                              },
                            )
                            :
                            PopupMenuItem(
                              value: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.offline_bolt),
                                  Text("enable"),
                                ],
                              ),
                              onTap: ()async{
                                // change member status
                                memberData[Constants.status] = Constants.enable;
                                final list = messProvaider.getMessModel!.messMemberList;
                                list[index] = memberData;
                                messProvaider.setMessModel(messMemberList: list);
                                await messProvaider.changeMemberStatus();
                                
                              },
                            ),
                        ];
                      },
                    ),
                  ),
                );
                },
                        );
               },
            );
          }
        } 
      ),
    );
  }
}