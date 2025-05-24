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

  Member memberScreemItemGrpup = Member.members;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }



  Widget getListOfMember(){
    final messProvaider = context.watch<MessProvaider>();
    final authProvaider = context.watch<AuthenticationProvider>();
    if(authProvaider.userModel!.currentMessId == ""){
      return Text("You are not connected to any mess.");
    } 
    messProvaider.getMessData(messId: authProvaider.userModel!.currentMessId, onFail: (String ) {showSnackber(context: context, content: "Mess Data Did Not Found");}, );
    return Expanded(
      child: FutureBuilder(
        future:messProvaider.getListOfMessMemberData(listOfMember: messProvaider.getMessModel!.messMemberList.map((x)=> x.toString()).toList()) ,
        builder:(context, AsyncSnapshot<List<UserModel>>snapshot) { 
          if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's save 
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No invitations found.'));
          }
          else{
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserModel memberData = snapshot.data![index];
                String memberType = 
                  messProvaider.getMessModel!.messAuthorityId==memberData.uId? 
                    Constants.menager
                    : messProvaider.getMessModel!.messAuthorityId2nd==memberData.uId? 
                    Constants.actMenager : Constants.member;

                return  Card(

                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 10),
                  leading: CircleAvatar(
                    child: Text(index.toString()),
                    backgroundColor: memberType==Constants.member? Colors.amber :Colors.red,
                  ),
                  title: Text(memberData.fname),
                  subtitle: Text("${memberData.createdAt}   ($memberType)"),
                  trailing: PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) {  
                      return [
                          PopupMenuItem(
                            onTap: (){
              
                            },
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.transfer_within_a_station_sharp),
                                Text("Transfer Owner"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: ()async{
                              bool? a = await showConfirmDialog(context: context, title: "Do You Want to Transfer The Ownership?");
                              if(a??false){
                                debugPrint("YES--------------");
                              }
                              else{
                                debugPrint("NO--------------");
                              }
                            },
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.highlight_remove_outlined),
                                Text("kick"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: (){
              
                            },
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.do_not_disturb_alt_outlined),
                                Text("Hold"),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
                ),
              );
              },
          );
                }
        } 
      ),
    );
  }
}