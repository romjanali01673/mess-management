import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/mess/mess_create.dart';
import 'package:meal_hisab/mess/mess_delete.dart';
import 'package:meal_hisab/mess/mess_update.dart';

class MessScreen extends StatefulWidget{
  const MessScreen({super.key});

  @override
  State<MessScreen>createState()=>_MessScreenState();

}

class _MessScreenState extends State<MessScreen>{
  Mess messScreemItemGrpup = Mess.mess;
  bool showComment = false;

  @override
  Widget build(BuildContext context){
    return Container(
      
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                spacing: 10,
                children: [
                  getMenuItems(
                    label: "Mess", 
                    ontap: (){
                      setState(() {
                        messScreemItemGrpup = Mess.mess;
                      });
                    },
                    selected: messScreemItemGrpup==Mess.mess,
                    icon: Icons.group
                  ),
                  getMenuItems(
                    label: "Create Mess", 
                    ontap: (){
                      setState(() {
                        messScreemItemGrpup = Mess.messCreate;
                      });
                    },
                    selected: messScreemItemGrpup==Mess.messCreate,
                    icon: Icons.group
                  ),
                  getMenuItems(
                    label: "Delete Mess", 
                    ontap: (){
                      setState(() {
                        messScreemItemGrpup = Mess.messDelete;
                      });
                    },
                    selected: messScreemItemGrpup==Mess.messDelete,
                    icon: Icons.group
                  ),
                  getMenuItems(
                    label: "Update Mess", 
                    ontap: (){
                      setState(() {
                        messScreemItemGrpup = Mess.messUpdate;
                      });
                    },
                    selected: messScreemItemGrpup==Mess.messUpdate,
                    icon: Icons.group
                  ),
                  getMenuItems(
                    label: "Invaitations", 
                    ontap: (){
                      setState(() {
                        messScreemItemGrpup = Mess.messInvitations;
                        
                      });
                    },
                    selected: messScreemItemGrpup==Mess.messInvitations,
                    icon: (Icons.add_circle_outline_outlined),
                  ),
                ],
              ),
          ),
          messScreemItemGrpup==Mess.messCreate? MessCreate()
          :
          messScreemItemGrpup==Mess.messDelete? MessDelete()
          :
          messScreemItemGrpup==Mess.messUpdate? MessUpdate()
          :
          getMessRolusAndRagilations()
        ],
      ),
    );
  }

  Widget getMessRolusAndRagilations(){
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context,index){
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text(index.toString()),
                        ),
                        title: Text("Mess Details Info"),
                        subtitle: Row(children:[ Text("40m"), Icon(Icons.group)]),
                        trailing: 
                        // Text("data"),
                        Row(
                              mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: (){} , icon: Icon(Icons.more_horiz), iconSize: 30,),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Text("mess name: \n owner name: \n owner contact:\n created at \n ETC \n\n\n roule -1 everyone can place his/her oppinion about this roules\n everyone should checked the giben rouls what is given in under", textAlign: TextAlign.start, style: TextStyle(fontSize: 18),),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text("5.6M"),
                              SizedBox(height: 10,),
                              GestureDetector(
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.thumbsUp),
                                    SizedBox(width: 10,),
                                    Text("Like"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text("1.3k"),
                              SizedBox(height: 10,),
                              GestureDetector(
                                onTap: (){showComment = (!showComment==true); setState(() {
                              
                                  });
                                },
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.comment),
                                    SizedBox(width: 10,),
                                    Text("Comment"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      showComment?
                      
                      Divider(
                        thickness: 2,
                        height: 20,
                      ) 
                      :
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                );
              }
            ),
          )
        ],
      )
    );
  }
}