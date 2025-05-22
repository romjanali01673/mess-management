
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class DipositeHistory extends StatefulWidget {
  const DipositeHistory({super.key});

  @override
  State<DipositeHistory> createState() => _DipositeHistoryState();
}

class _DipositeHistoryState extends State<DipositeHistory> {
  HistoryOfDiposite historyOfDipositeItemGroup = HistoryOfDiposite.allHostory;
  List<Map<String, List>> month = [
    
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    //  "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
  ];


  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Column(
        children: [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  spacing: 10,
                  children: [
                    getMenuItems(
                      label: "All History", 
                      ontap: (){
                        historyOfDipositeItemGroup = HistoryOfDiposite.allHostory;
                        setState(() {
                          
                        });
                            
                      },
                      selected: historyOfDipositeItemGroup == HistoryOfDiposite.allHostory,
                    ),
                    getMenuItems(
                      icon: Icons.add_box_rounded,
                      label: "Member Wise", 
                      ontap: (){
                        historyOfDipositeItemGroup = HistoryOfDiposite.memberWise;
                        setState(() {
                          
                        });
                            
                      },
                      selected: historyOfDipositeItemGroup == HistoryOfDiposite.memberWise,
                    ),
                  ],
                ),
              ),
            ),
            historyOfDipositeItemGroup== HistoryOfDiposite.memberWise? getHistoryMemberWise()
            :
            getAllHistoryOfDiposite()
            
        ],
      ),
    );
  }


  Widget getAllHistoryOfDiposite(){
    return Expanded(
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
                            onTap: () {
                              
                            }, 

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
          );
  }

  Widget getHistoryMemberWise(){
    return Expanded(
            child: ListView(
              children: month.asMap().entries.map((val){
                int index = val.key;
                Map<String, List> monthName = val.value;
                
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        
                        onTap: () {
                          monthName[monthName.keys.first]![0] = !monthName[monthName.keys.first]![0];
                          setState(() {
                            
                          });
                          if(monthName[monthName.keys.first]![0]){
                            debugPrint("Hello romjan how are you?");
                          }
                          else{
                            debugPrint("Hello romjan how are you?-----");
                      
                          }
                        },
                        title: Text("${monthName.keys}"),
                        subtitle: Text("ID: 12345678"),
                        leading: CircleAvatar(
                          child: Text("${index+1}"),
                        ),
                        trailing: monthName[monthName.keys.first]![0] ? Icon(Icons.arrow_drop_down_rounded) : Icon(Icons.arrow_right),
                      ),
                      if(monthName[monthName.keys.first]![0])...[
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am bjgj jjkjhkh kjhkhkhkkj kh  a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                      ]
                    ],
                  ),
                );
              }).toList(),
            ),
          );
  }


}