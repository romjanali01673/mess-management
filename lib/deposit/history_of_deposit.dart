
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/deposit_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/deposit_provaider.dart';
import 'package:provider/provider.dart';

class DepositHistory extends StatefulWidget {
  const DepositHistory({super.key});

  @override
  State<DepositHistory> createState() => _DepositHistoryState();
}

class _DepositHistoryState extends State<DepositHistory> {
  HistoryOfDeposit historyOfDepositItemGroup = HistoryOfDeposit.allHostory;
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
                        historyOfDepositItemGroup = HistoryOfDeposit.allHostory;
                        setState(() {
                          
                        });
                            
                      },
                      selected: historyOfDepositItemGroup == HistoryOfDeposit.allHostory,
                    ),
                    getMenuItems(
                      icon: Icons.add_box_rounded,
                      label: "Member Wise", 
                      ontap: (){
                        historyOfDepositItemGroup = HistoryOfDeposit.memberWise;
                        setState(() {
                          
                        });
                            
                      },
                      selected: historyOfDepositItemGroup == HistoryOfDeposit.memberWise,
                    ),
                  ],
                ),
              ),
            ),
            historyOfDepositItemGroup== HistoryOfDeposit.memberWise? getHistoryMemberWise()
            :
            getAllHistoryOfDeposit()
            
        ],
      ),
    );
  }


  Widget getAllHistoryOfDeposit(){
    final depositProvaider  = context.read<DepositProvaider>();
    final authProvaider  = context.read<AuthenticationProvider>();
    return Expanded(
      child: FutureBuilder(
        future: depositProvaider.getAllDepositList(
          messId: authProvaider.getUserModel!.currentMessId, 
          onFail: (message ) { 
            showSnackber(context: context, content: "somthing Wrong! \n$message");
          },
        ), 
        builder: (context, AsyncSnapshot<List<Map<String,dynamic>>?> snapshot){
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
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index){
              DepositModel depositModel = snapshot.data![index][Constants.deposit];
              Map<String,dynamic> userData = snapshot.data![index][Constants.userData];
              bool showDetails = false;
              return StatefulBuilder(
                builder:(context, setLocalState){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 10),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text("${index+1}"),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${userData[Constants.fname]}"),
                            Text("Type: ${depositModel.type}"),
                          ],
                        ),
                        subtitle: Text("Time: ${DateFormat("hh:mm a dd-MM-yyyy").format(depositModel.CreatedAt!.toDate().toLocal())}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${depositModel.amount}", style: TextStyle(fontSize: 18),),
                            showDetails? Icon(Icons.arrow_downward_rounded):Icon(Icons.arrow_right_rounded),
                          ],
                        ),
                        onTap: () {
                          setLocalState((){
                            showDetails = !showDetails;
                          });
                        },
                      ),
                      if(showDetails) Column(
                        spacing: 5,
                        children: [
                          Text("UId: ${userData[Constants.uId]}"),
                          Text("Tnx Id: ${depositModel.transactionId}"),
                          Text("description: ${depositModel.description==""? "Empty!" : depositModel.description}" ),
                        ]
                      
                      )
                    ],
                  );
                } 
              );
            }
          );
        }
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
                        title: Text("name"),
                        subtitle: Text("ID: 12345678"),
                        leading: CircleAvatar(
                          child: Text("${index+1}"),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("234"),
                            monthName[monthName.keys.first]![0] ? Icon(Icons.arrow_drop_down_rounded) : Icon(Icons.arrow_right),
                          ],
                        ),
                      ),
                      if(monthName[monthName.keys.first]![0])...[
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