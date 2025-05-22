import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/member/add_member.dart';

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
    return Expanded(
      child: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          return  Card(
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 10),
            leading: CircleAvatar(
              child: Text(""),
              backgroundColor: Colors.amber,
            ),
            title: Text("Md Romjan Ali"),
            subtitle: Text("12345678   (Member)"),
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
           ),
    );
  }
}