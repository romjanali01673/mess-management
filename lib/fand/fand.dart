import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/fand/add_cost.dart';
import 'package:meal_hisab/fand/add_diposite.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class FandScreen extends StatefulWidget {
  const FandScreen({super.key});

  @override
  State<FandScreen> createState() => _FandScreenState();
}

class _FandScreenState extends State<FandScreen> {
  int blance = 999999;
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
                      label: "Add Diposite", 
                      ontap: (){
                        fandItemGroup = Fand.addDiposite;
                        setState(() {
                          
                        });
                            
                      },
                      selected: fandItemGroup == Fand.addDiposite,
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
            fandItemGroup==Fand.addDiposite? AddDiposite() 
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
  int blance  = 9090;
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Card(
            color: Colors.green.shade500,
            child: ListTile(
              title: Text("Current Blance: $blance", style: TextStyle(fontSize: 20),),
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(itemBuilder: (context , index){
                return ListTile(
                  contentPadding: EdgeInsets.only(left: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Text("$index"),
                  ),
                  title: Text("Md Romjan Ali"),
                  subtitle: Text("${DateTime.now()}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("121212", style: TextStyle(fontSize: 18),),
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
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}