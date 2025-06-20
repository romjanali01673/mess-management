import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/fand/add_cost.dart';
import 'package:meal_hisab/fand/add_deposit.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/fand_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/fand_provider.dart';
import 'package:meal_hisab/ui_helper/ui_helper.dart';
import 'package:provider/provider.dart';

class FandScreen extends StatefulWidget {
  const FandScreen({super.key});

  @override
  State<FandScreen> createState() => _FandScreenState();
}

class _FandScreenState extends State<FandScreen> {
  Fand fandItemGroup = Fand.fand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  spacing: 10,
                  children: [
                    getMenuItems(
                      label: "Fand", 
                      ontap: (){
                        fandItemGroup = Fand.fand;
                        setState(() {
                          
                        });
                            
                      },
                      selected: fandItemGroup == Fand.fand,
                    ),
                    getMenuItems(
                      icon: Icons.add_box_rounded,
                      label: "Add Deposit", 
                      ontap: (){
                        fandItemGroup = Fand.addDeposit;
                        setState(() {
                          
                        });
                            
                      },
                      selected: fandItemGroup == Fand.addDeposit,
                    ),
                    getMenuItems(
                      icon: FontAwesomeIcons.circleMinus,
                      label: "Add Cost", 
                      ontap: (){
                        fandItemGroup = Fand.addCost;
                        setState(() {
                          
                        });
                            
                      },
                      selected: fandItemGroup == Fand.addCost,
                    ),
                  ],
                ),
              ),
            ),
            fandItemGroup==Fand.addDeposit? AddDeposit() 
            :
            fandItemGroup==Fand.addCost? AddCost()
            :
            FandHome(),
          ],     
        ),
      ),
    );
  }
}


class FandHome extends StatefulWidget {
  const FandHome({super.key});

  @override
  State<FandHome> createState() => _FandHomeState();
}

class _FandHomeState extends State<FandHome> {

  bool showBlance = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    FandProvider fandProvider = context.read<FandProvider>();
    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();

    return Expanded(
      child: Column(
        children: [
          StatefulBuilder(
            builder: (context, setLocalState) {
              return FutureBuilder(
                future: fandProvider.getFandBlance(messId: authProvider.getUserModel!.currentMessId, onFail: (_){}),
                builder: (context, AsyncSnapshot snapshot) {
                  return Card(
                    color: Colors.green.shade500,
                    child: ListTile(
                      trailing: IconButton(
                        onPressed: (){
                          setLocalState(() {
                          showBlance = !showBlance;
                            
                          });
                        }, 
                        icon: showBlance? Icon(Icons.remove_red_eye_sharp) : Icon(Icons.remove_red_eye_outlined),
                      ),
                      title: 
                      showBlance? Text("Current Blance: ${fandProvider.getBlance}",)
                      :
                      Text("tap to see blance"),
                    ),
                  );
                }
              );
            }
          ),
          Expanded(
            child: Container(
              child: FutureBuilder(
                future: fandProvider.getFandTransactions(
                  messId: authProvider.getUserModel!.currentMessId, 
                  onFail: (message) { 
                    showSnackber(context: context, content: "");
                  }, 
                  onSuccess: () {
                    
                  }
                ),
                builder: (BuildContext context, AsyncSnapshot<List<FandModel>?> snapshot) { 
                  if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                    return Center(child: showCircularProgressIndicator());
                  }
                  else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } 
                  else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No Transaction found.'));
                  }
                  return ListView.builder(
                    itemCount:snapshot.data!.length,
                    itemBuilder: (context , index){
                    bool showDetails = false;
                    final fandmodel = snapshot.data![index]; 
                    
                    return StatefulBuilder(
                      builder: (context, setLocalState) {
                        return Card(
                          color: fandmodel.type==Constants.add? Colors.green.shade50:Colors.red.shade50,
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  setLocalState((){
                                    showDetails = !showDetails;
                                  });
                                },
                                contentPadding: EdgeInsets.only(left: 10),
                                leading: Text("${index+1}",),
                                title: Text(fandmodel.title),// title
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${fandmodel.type}"), // type
                                    Text("${DateFormat("hh:mm a dd-MM-yyyy").format(fandmodel.CreatedAt!.toDate().toLocal())}"),
                                    // Text((fandmodel.CreatedAt!.toDate().toString())),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${fandmodel.amount%1==0? fandmodel.amount.toInt().toString() : fandmodel.amount.toString()}", style: TextStyle(fontSize: 18),),// amount
                                    PopupMenuButton(
                                      icon: Icon(Icons.more_vert),
                                      itemBuilder: (context) =>[
                                        
                                        PopupMenuItem(
                                          value: 0,
                                          child: ListTile(
                                            title: Text("Edit"),
                                            leading: Icon(Icons.edit),
                                            ), 
                                        ),
                              
                                        PopupMenuItem(
                                          value: 1,
                                          // onTap: (){
                                          //   // if i use this function. we don't need to Navigator.pop()
                                          // },
                                          child: ListTile(
                                            title: Text("Delete"),
                                            leading: Icon(Icons.delete),
                                            onTap: ()async{
                                              Navigator.pop(context); // if i use this function. we have to Navigator.pop() for close listview and can't called parent/PopupMenuItem's ontap function
                                              bool? confirm = await showDialog(context: context, builder: (content)=>AlertDialog(
                                                title: Text("Do you want to delete?"),
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
                                              }
                                              else{
                                                  debugPrint("Confirmed false ------------");
                                              }
                                            },
                                          ), 
                                        ),
                                      ]
                                    )
                                  ],
                                ),
                              ),
                              if(showDetails)Text("${fandmodel.description}"),
                        
                            ],
                          ),
                        );
                      }
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}