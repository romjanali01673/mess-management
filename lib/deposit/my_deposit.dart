
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/deposit_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/deposit_provider.dart';
import 'package:provider/provider.dart';

class MyDeposit extends StatefulWidget {
  final bool fromPreMember;
  final String? messId;
  final String? mealSessionId;
  final String? uId;
  const MyDeposit({super.key, this.fromPreMember = false, this.messId, this.mealSessionId, this.uId});

  @override
  State<MyDeposit> createState() => _MyDepositState();
}

class _MyDepositState extends State<MyDeposit> {
  bool showTotalDeposit = false;
  
  @override
  Widget build(BuildContext context) {
    final depositProvider  = context.read<DepositProvider>();
    final authProvider  = context.read<AuthenticationProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
              SizedBox(
                height:Platform.isIOS? 40:10,
              ),
         if(!widget.fromPreMember) StatefulBuilder(
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
                    icon: showTotalDeposit? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                  ),
                  title: 
                  showTotalDeposit? 
                  FutureBuilder(
                    future: depositProvider.getDepositAmount(
                      messId: authProvider.getUserModel!.currentMessId,
                      mealSessionId: authProvider.getUserModel!.mealSessionId,
                      uId: authProvider.getUserModel!.uId,
                      onFail: (message){
                        SchedulerBinding.instance.addPostFrameCallback((_){
                          showSnackber(context: context, content: "somthing Wrong! \n$message");
                        });
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
                      return Text("Total Meal: ${depositProvider.getTotalDeposit}",);
                    }
                  )
                  :
                  Text("tap to see Meal"),
                ),
              );
           }
         ),
    
          // here my deposit list.
          FutureBuilder(
            future: widget.fromPreMember? depositProvider.getMemberDepositList(//get Member Deposit List For A Spacific Session
              messId: widget.messId!,
              mealSessionId: widget.mealSessionId!,
              uId: widget.uId!,
              onFail: (message){
                SchedulerBinding.instance.addPostFrameCallback((_){
                  showSnackber(context: context, content: "somthing Wrong! \n$message");
                });
              },
            )
            :
            depositProvider.getMemberDepositList(
              messId: authProvider.getUserModel!.currentMessId, 
              mealSessionId: authProvider.getUserModel!.mealSessionId, 
              uId: authProvider.getUserModel!.uId,
              onFail: (message ) { 
                SchedulerBinding.instance.addPostFrameCallback((_){
                  showSnackber(context: context, content: "somthing Wrong! \n$message");
                });
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text('No Transaction found.'),
                  );
              }
              return ListView.builder(
                // reverse: true,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                            title: Row(
                              children: [
                                Text("Type: ",),
                                Text("${depositModel.type}", style: TextStyle(color:depositModel.type==Constants.deposit?Colors.green:Colors.red ),),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tnx Id: ${depositModel.tnxId}"),
                                Text("Time: ${DateFormat("hh:mm a dd-MM-yyyy").format(depositModel.CreatedAt!.toDate().toLocal())}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                showPrice(value: depositModel.amount),
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
        ],
      ),
    );
  }
}