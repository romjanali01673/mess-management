
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/deposit_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/deposit_provaider.dart';
import 'package:provider/provider.dart';

class MyDeposit extends StatefulWidget {
  const MyDeposit({super.key});

  @override
  State<MyDeposit> createState() => _MyDepositState();
}

class _MyDepositState extends State<MyDeposit> {
  bool showTotalDeposit = false;
  
  @override
  Widget build(BuildContext context) {
    final depositProvaider  = context.read<DepositProvaider>();
    final authProvaider  = context.read<AuthenticationProvider>();

    return Expanded(
      child: Column(
        children: [
         StatefulBuilder(
           builder: (context, setLocalState) {
             return Card(
                color: Colors.green.shade500,
                child: ListTile(
                  trailing: IconButton(
                    onPressed: (){
                      setLocalState(() {
                      showTotalDeposit = !showTotalDeposit;
                        
                      });
                    }, 
                    icon: showTotalDeposit? Icon(Icons.remove_red_eye_sharp) : Icon(Icons.remove_red_eye_outlined),
                  ),
                  title: 
                  showTotalDeposit? 
                  FutureBuilder(
                    future: depositProvaider.getDepositAmount(
                      messId: authProvaider.getUserModel!.currentMessId,
                      uId: authProvaider.getUserModel!.uId,
                      onFail: (message){
                        showSnackber(context: context, content: "somthing Wrong! \n$message");
                      },
                    ),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                        return Center(child: showCircularProgressIndicator());
                      }
                      // else if (snapshot.hasError) {
                      //     return Center(child: Text('Error: ${snapshot.error}'));
                      // } 
                      // else if (!snapshot.hasData || snapshot.data == null) {
                      //     return Center(child: Text('No Transaction found.'));
                      // }
                      return Text("Total Meal: ${depositProvaider.getTotalDeposit}",);
                    }
                  )
                  :
                  Text("tap to see Meal"),
                ),
              );
           }
         ),

          // here my deposit list.
          Expanded(
            child: FutureBuilder(
              future: depositProvaider.getMemberDepositList(
                messId: authProvaider.getUserModel!.currentMessId, 
                uId: authProvaider.getUserModel!.uId,
                onFail: (message ) { 
                  showSnackber(context: context, content: "somthing Wrong! \n$message");
                },
              ), 
              builder: (context, AsyncSnapshot<List<DepositModel>?> snapshot){
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
                  // reverse: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index){
                    DepositModel depositModel = snapshot.data![index];
                    bool showDetails = false;
                    return StatefulBuilder(
                      builder:(context, setLocalState){
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 10),
                              leading: CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Text("${index+1}"),
                              ),
                              title: Text("Type: ${depositModel.type}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tnx Id: ${depositModel.transactionId}"),
                                  Text("Time: ${DateFormat("hh:mm a dd-MM-yyyy").format(depositModel.CreatedAt!.toDate().toLocal())}"),
                                ],
                              ),
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
                            if(showDetails)...[
                              // show description here 
                              Text(depositModel.description==""? "Description are Empty!" : depositModel.description),
                            ]
                          ],
                        );
                      } 
                    );
                  }
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}