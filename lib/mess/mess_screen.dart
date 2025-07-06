import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/mess/add_rule.dart';
import 'package:mess_management/mess/close_mess_hisab.dart';
import 'package:mess_management/mess/join_or_leave.dart';
import 'package:mess_management/mess/mess_create.dart';
import 'package:mess_management/mess/mess_delete.dart';
import 'package:mess_management/mess/mess_update.dart';
import 'package:mess_management/pre_data/pre_data.dart';
import 'package:mess_management/model/rule_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MessScreen extends StatefulWidget{
  const MessScreen({super.key});

  @override
  State<MessScreen>createState()=>_MessScreenState();

}

class _MessScreenState extends State<MessScreen>{
  Mess messScreemItemGrpup = Mess.mess;
  bool showComment = false;


  @override
  void initState() {
    super.initState();
    // Delay getting screen size until layout is built
    WidgetsBinding.instance.addPostFrameCallback((_)async {
      await Future.delayed(Duration(milliseconds: 100));
    });
  }

  @override
  Widget build(BuildContext context){
    MessProvider messProvider = context.read<MessProvider>();
    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(messProvider.getMessModel?.messName?? "Mess Name"),
        backgroundColor: Colors.grey,
        actions: [
          if(messScreemItemGrpup==Mess.mess)
          IconButton(
            onPressed: () {
              if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                showSnackber(context: context, content: "Required Administrator Power");
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddRule()));
            },
            icon: Icon(Icons.add, color: Colors.black, size: 35,)
          ),
        ],
      ),
      body: Container(
        color: Colors.green.shade50,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  spacing: 10,
                  children: [
                    getMenuItems(
                      label: "About Mess", 
                      ontap: (){
                        setState(() {
                          messScreemItemGrpup = Mess.mess;
                        });
                      },
                      selected: messScreemItemGrpup==Mess.mess,
                      icon: Icons.info_outline_rounded
                    ),
                    getMenuItems(
                      label: "Close Mess Estimate", 
                      ontap: (){
                        // navigate "Close Mess Estimate" page
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MessCloseScreen()));
        
                      },
                      icon: Icons.settings_power_outlined
                    ),
                    getMenuItems(
                      label: "Join/leave", 
                      ontap: (){
                        setState(() {
                          messScreemItemGrpup = Mess.joinOrleave;
                          
                        });
                      },
                      selected: messScreemItemGrpup==Mess.joinOrleave,
                      icon: (Icons.library_add),
                    ),
                    getMenuItems(
                      label: "Update Mess", 
                      ontap: (){
                        setState(() {
                          messScreemItemGrpup = Mess.messUpdate;
                        });
                      },
                      selected: messScreemItemGrpup==Mess.messUpdate,
                      icon: Icons.update_sharp
                    ),
                    getMenuItems(
                      label: "Delete Mess", 
                      ontap: (){
                        setState(() {
                          messScreemItemGrpup = Mess.messDelete;
                        });
                      },
                      selected: messScreemItemGrpup==Mess.messDelete,
                      icon: Icons.delete
                    ),
                    getMenuItems(
                      label: "Create Mess", 
                      ontap: (){
                        setState(() {
                          messScreemItemGrpup = Mess.messCreate;
                        });
                      },
                      selected: messScreemItemGrpup==Mess.messCreate,
                      icon: Icons.create
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
            messScreemItemGrpup==Mess.joinOrleave? JoinOrLeave()
            :
            getMessInSideData()
          ],
        ),
      ),
    );
  }

  Widget getMessInSideData(){
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                  
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.info,size: 30,),
                    ),
                    title: Text("Mess Details Info",style : getTextStyleForTitleM()),
                    // subtitle: Icon(Icons.group),
                    trailing: 
                    // Text("data"),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: (){} , icon: Icon(Icons.more_horiz), iconSize: 30,),
                      ],
                    ),
                  ),
                  if(messProvider.getMessModel!=null) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 
                        Text(
                          "Mess Name: ${messProvider.getMessModel!.messName}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold)
                        ),
                        Text(
                          "Mess Id: ${messProvider.getMessModel!.messId}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Menager Name: ${messProvider.getMessModel!.menagerName}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Menager Id: ${messProvider.getMessModel!.menagerId}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Menager Email: ${messProvider.getMessModel!.menagerEmail}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Menager Phone: ${messProvider.getMessModel!.menagerPhone}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Act Menager Name: ${messProvider.getMessModel!.actMenagerName}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Act Menager Id: ${messProvider.getMessModel!.actMenagerId}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Number Of Member: ${messProvider.getMessModel!.messMemberList.length}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Meal Session Id: ${messProvider.getMessModel!.mealSessionId}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Mess Address: ${messProvider.getMessModel!.messAddress}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                        if(messProvider.getMessModel!.createdAt != null) Text(// because ait first when we create a mess we did not read data from firebase just set given data to current mess data. for this mement we gat a error for null Timestamp
                          "Created At: ${DateFormat("hh:mm a dd-MM-yyyy").format(messProvider.getMessModel!.createdAt!.toDate().toLocal())}",
                          style : getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        
            Padding(
              padding: const EdgeInsets.only(top: 20,bottom: 10),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Mess Inside Rules", style: getTextStyleForSubTitleXL().copyWith(fontWeight: FontWeight.bold),),
                  Icon(Icons.arrow_downward_outlined),
                ],
              ),
            ),
            
            FutureBuilder(
              future: messProvider.getMessRules(messId:authProvider.getUserModel!.currentMessId, onFail:(_){}),
              builder: (context, AsyncSnapshot<List<RuleModel>?> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                  return Center(child: showCircularProgressIndicator());
                }
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } 
                else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nothing.'));
                }
                return ListView.builder(
                  shrinkWrap: true, // ← This is the key
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context,index){
                    RuleModel ruleModel = snapshot.data![index];
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Text(index.toString()),
                            ),
                            title: Text("${ruleModel.title}",style : getTextStyleForTitleS()),
                            subtitle: Text("${DateFormat("hh:mm a dd-MM-yyyy").format(messProvider.getMessModel!.createdAt!.toDate().toLocal())}",style: getTextStyleForSubTitleM()),
                            trailing: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context) =>[  
                                PopupMenuItem(
                                  value: 0,
                                  child: ListTile(
                                    title: Text("Edit",style : getTextStyleForTitleM()),
                                    leading: Icon(Icons.edit, color: Colors.green,),
                                  ), 
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AddRule(preRuleModel: ruleModel,)));
                                  },
                                ),
                              
                                PopupMenuItem(
                                  value: 1,
                                  // onTap: (){
                                  //   // if i use this function. we don't need to Navigator.pop()
                                  // },
                                  child: ListTile(
                                    title: Text("Delete",style : getTextStyleForTitleM()),
                                    leading: Icon(Icons.delete, color: Colors.red,),
                                    onTap: ()async{
                                      Navigator.pop(context); // if i use this function. we have to Navigator.pop() for close listview and can't called parent/PopupMenuItem's ontap function
                                      bool? confirm = await showDialog(context: context, builder: (content)=>AlertDialog(
                                        title: Text("Do you want to delete?",style : getTextStyleForTitleM()),
                                        actionsAlignment: MainAxisAlignment.start,
                                        actions: [
                                          TextButton(child: Text("No"), onPressed: (){
                                            Navigator.pop(context, false);
                                          },),
                                          TextButton(child: Text("Yes") , onPressed: (){
                                          Navigator.pop(context, true);
                                          },),
                                        ],
                                      ));
                                      if(confirm!=null && confirm){
                                        debugPrint("Confirmed ------------");
                                        await messProvider.deleteAMessRule(
                                          messId: authProvider.getUserModel!.currentMessId, 
                                          tnxId: ruleModel.tnxId, 
                                          onFail: (message ) {
                                            print("failed");
                                            showSnackber(context: context, content: "Deletion Failed!\n$message");
                                          },
                                          onSuccess: (){
                                            print("success");
                                            setState(() {
                                              showSnackber(context: context, content: "Deletion Successed.");
                                            });
                                          }
                                        );
                                      }
                                    },
                                  ), 
                                ),
                              ]
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("ID: ${ruleModel.tnxId}\n",
                                  style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text("${ruleModel.description}",
                                  style: getTextStyleForSubTitleM(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                );
              }
            )
          ],
        ),
      )
    );
  }
}