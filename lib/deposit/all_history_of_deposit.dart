
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/deposit_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/deposit_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class AllHistoryOfDeposit extends StatefulWidget {
  const AllHistoryOfDeposit({super.key});

  @override
  State<AllHistoryOfDeposit> createState() => _AllHistoryOfDepositState();
}

class _AllHistoryOfDepositState extends State<AllHistoryOfDeposit> {
  bool  showTotalDepositOfMess = false;

  @override
  Widget build(BuildContext context) {
    final depositProvider  = context.read<DepositProvider>();
    final messProvider  = context.read<MessProvider>();
    final authProvider  = context.read<AuthenticationProvider>();
    return SingleChildScrollView(
      child: 
      (!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider)))?
      SizedBox(
        height: 500,
        child: Center(
          child: Text("Required Administrator Power!"),
        ),
      )
      :
      Column(
        children: [
              SizedBox(
                height:Platform.isIOS? 40:10,
              ),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return Card(
                     color: Colors.green.shade500,
                     child: ListTile(
                       trailing: IconButton(
                         onPressed: (){
                           setLocalState(() {
                           showTotalDepositOfMess = !showTotalDepositOfMess;
      
                           });
                         }, 
                         icon: showTotalDepositOfMess? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                       ),
                       title: 
                       showTotalDepositOfMess? 
                       FutureBuilder(
                         future: depositProvider.getDepositAmount(
                           messId: authProvider.getUserModel!.currentMessId,
                           mealSessionId: authProvider.getUserModel!.mealSessionId,
                           uId: authProvider.getUserModel!.uId,
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
                           return Row(
                             children: [
                               Expanded(child: Text("Total Deposit Of Mess: ",)),
                               showPrice(value: depositProvider.getTotalDepositOfMess),
                             ],
                           );
                         }
                       )
                       :
                       Text("See Deposited Amount Of Mess"),
                     ),
                   );
                }
              ),
      
          FutureBuilder(
            future: depositProvider.getAllDepositList(
              messId: authProvider.getUserModel!.currentMessId, 
              mealSessionId: authProvider.getUserModel!.mealSessionId, 
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
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index){
                  DepositModel depositModel = snapshot.data![index][Constants.depositModel];
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
                                Row(
                                  children: [
                                    Text("Type: ",),
                                    Text("${depositModel.type}", style: TextStyle(color:depositModel.type==Constants.deposit?Colors.green:Colors.red ),),
                                  ],
                                ),
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
                              Text("Tnx Id: ${depositModel.tnxId}"),
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
        ],
      ),
    );
  }
}