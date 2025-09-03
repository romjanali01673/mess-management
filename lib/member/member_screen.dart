import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/member/add_member.dart';
import 'package:mess_management/model/user_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  bool _isDisposed = false;

  Member memberScreemItemGrpup = Member.members;
  @override
  void initState(){
    
    super.initState();
    // final messProvider = context.read<MessProvider>();
    // final authProvider = context.read<AuthenticationProvider>();
    // if(authProvider.getUserModel!.currentMessId == ""){
    //   setState(() {
    //     otherWiseScreen =  Text("You are not connected to any mess.");
    //     showScreen = false;
    //   });
    // } 
    // else{
    //   messProvider.getMessData(
    //     messId: authProvider.getUserModel!.currentMessId,
    //     onFail: (message){
    //       setState(() {
    //         showScreen = false;
    //         showSnackber(context: context, content: "Mess Data Did Not Found\n$message");
    //         otherWiseScreen =  Text("Somthing Wrong\n try again");
    //       });
    //     }, 
    //     onSuccess: () {
    //       setState(() {
    //         showScreen = true;
    //       });
    //     },
    //   );
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isDisposed = true;
    super.dispose();
  }



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

    final messProvider = context.watch<MessProvider>();
    // final messProvider = context.watch<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    return Expanded(
      child: 
          (messProvider.isLoading) ? Center(child: CircularProgressIndicator())
          :
          (messProvider.getMessModel==null ||messProvider.getMessModel!.messMemberList.isEmpty )? Center(child: Text('No member found.'))
          :  StatefulBuilder(
              builder: (context, setLocalState) { 

              return ListView.builder(
                itemCount: messProvider.getMessModel!.messMemberList.length,
                itemBuilder: (context, index) {
                  Map<String,dynamic> memberData = messProvider.getMessModel!.messMemberList[index];
                  String memberType = 
                    messProvider.getMessModel!.menagerId==memberData[Constants.uId]? 
                      Constants.menager
                      : messProvider.getMessModel!.actMenagerId==memberData[Constants.uId]? 
                      Constants.actMenager : Constants.member;
              
                  return  Card(
              
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 10),
                    leading: CircleAvatar(
                      backgroundColor: memberType==Constants.member? Colors.amber :Colors.red,
                      child: Text((index+1).toString()),
                    ),
                    title: Text(memberData[Constants.fname],style : getTextStyleForTitleM()),
                    subtitle: Text("${memberData[Constants.uId]}   ($memberType)"),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) {  
                        return [
                            PopupMenuItem(
                              onTap: ()async{
                                if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                                  showSnackber(context: context, content: "Required Administrator Power");
                                  return;
                                }
                                UserModel? userModel =  await authProvider.getMemberData(uId: memberData[Constants.uId]);
                                // show details in a dialog box.
                                if(userModel!=null){
                                  showMessageDialog(
                                    context: context,
                                    title: "Member Info", 
                                    Discreption: 
                                    "Image: Firestore Storage Paid \nName: ${userModel.fname} \nUser Id: ${userModel.uId} \nAddress: ${userModel.fullAddress} \nPhone: ${userModel.number} \nEmail: ${userModel.email}",
                                  );
                                }
                              },
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(FontAwesomeIcons.user),
                                  Text("See Details",style: getTextStyleForTitleS(),),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: ()async{
                                if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                                  showSnackber(context: context, content: "Required Administrator Power");
                                  return;
                                }
                                await messProvider.change2ndMessOwnership(
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
                                  Text("make Act Menager", style: getTextStyleForTitleS(),),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              onTap: ()async{
                                if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                                  showSnackber(context: context, content: "Required Administrator Power");
                                  return;
                                }
                                bool? a = await showConfirmDialog(context: context, title: "Kick", subTitle: "Are You Sure?");
                                if(a??false){
                                  // remove from mess
                                  await messProvider.kickMemberFromMess(member: memberData);
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.highlight_remove_outlined),
                                  Text("kick", style: getTextStyleForTitleS(),),
                                ],
                              ),
                            ),
              
                            PopupMenuItem(
                              value: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.do_not_disturb_alt_outlined),
                                  Text( memberData[Constants.status]==Constants.enable? "Disable" : "Enable", style: getTextStyleForTitleS(),),
                                ],
                              ),
                              onTap: ()async{
                                if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                                  showSnackber(context: context, content: "Required Administrator Power");
                                  return;
                                }
                                // change member status
                                Map<String,dynamic> newMemberData = Map.from(memberData);
                                newMemberData[Constants.status] = (memberData[Constants.status] == Constants.disable)? Constants.enable:Constants.disable ;
                                debugPrint(memberData.toString());
                                debugPrint(newMemberData.toString());
                                await messProvider.changeMemberStatus(preMemberData:  memberData, newMemberData: newMemberData);
                              },
                            )
                        ];
                      },
                    ),
                  ),
                );
                },
                        );
               },
          )
    );
  }
}