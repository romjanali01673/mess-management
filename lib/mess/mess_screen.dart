import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/fund/fand_list.dart';
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

class _MessScreenState extends State<MessScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final List<String> tabs = const [
    "About Mess", 
    "Close Mess Estimate",
    "Join/Leave", 
    "Update", 
    "Delete", 
    "Create",
  ];
  final List<Icon> icons =const [
    Icon(Icons.info_outline),
    Icon(Icons.settings_power_outlined),
    Icon(Icons.library_add),
    Icon(Icons.update),
    Icon(Icons.delete),
    Icon(Icons.create),
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, scrollable){
          return [
            SliverAppBar(
              backgroundColor: Colors.grey,
              title: AnimatedBuilder(
                animation: _tabController!,
                builder: (context, child) {
                  return Text(tabs[_tabController!.index]);
                },
              ),
              actions: [
                IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AddRule()));
                  }, 
                  icon: Icon(Icons.add),
                )
              ],
              floating: true,
              snap: true,
              pinned: true,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,// must assign otherwise get an error
                tabAlignment: TabAlignment.start,
                labelColor: Colors.black,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.black,
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                indicatorColor: Colors.black,
                tabs:tabs.map((e)=> Tab(text: e.toString() , icon:icons[tabs.indexOf(e)],)).toList(),
              ),
            ),
            
          ];
        },
        
        body:TabBarView(
          controller: _tabController,
          children: [
            AboutMess(),
            MessCloseScreen(),
            JoinOrLeave(),
            // MyWidget(),
            // MyWidget(),
            // MyWidget(),
            MessUpdate(),
            MessDelete(),
            MessCreate(),
          ],
        )
      ),
    );
  }
}


class AboutMess extends StatefulWidget {
  const AboutMess({super.key});

  @override
  State<AboutMess> createState() => _AboutMessState();
}

class _AboutMessState extends State<AboutMess> {
  @override
  Widget build(BuildContext context) {
    
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    return Scaffold(
      backgroundColor: Colors.lightGreen.shade50,
      body: SingleChildScrollView(
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
                bool showDetails = false;
                if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                  return Center(child: showCircularProgressIndicator());
                }
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } 
                else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nothing.'));
                }
                return StatefulBuilder(
                  builder: (context, setLocalState) {
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
                                onTap: (){
                                  setLocalState((){
                                    showDetails = !showDetails;
                                  });
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Text((index+1).toString()),
                                ),
                                title: Text("${ruleModel.title}",style : getTextStyleForTitleS()),
                                subtitle: Text("${DateFormat("hh:mm a dd-MM-yyyy").format(messProvider.getMessModel!.createdAt!.toDate().toLocal())}",style: getTextStyleForSubTitleM()),
                                trailing: PopupMenuButton(
                                  icon: Icon(Icons.more_vert),
                                  itemBuilder: (context) =>
                                  !(amIAdmin(messProvider: messProvider, authProvider: authProvider)||amIactmenager(messProvider: messProvider, authProvider: authProvider)) ?
                                  []
                                  :
                                  [  
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
                              if(showDetails)Padding(
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
                );
              }
            )
          ],
        ),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(child: Placeholder(color: Colors.red,));
  }
}