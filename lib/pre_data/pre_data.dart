import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/member_summary_model.dart';
import 'package:mess_management/model/mess_model.dart';
import 'package:mess_management/pre_data/meal_session_list.dart';
import 'package:mess_management/pre_data/member_summary.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class PreDataScreen extends StatefulWidget {
  const PreDataScreen({super.key});

  @override
  State<PreDataScreen> createState() => _PreDataScreenState();
}

class _PreDataScreenState extends State<PreDataScreen> {
  List<Map<String,dynamic>> messList=[];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: Text("Mess List"),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MealSessionList()));
            }, 
            icon: Icon(Icons.admin_panel_settings),
            color: Colors.black,
            iconSize: 40,
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder(
            future: messProvider.getAUserMessList(
              uId: authProvider.getUserModel!.uId, 
              onFail: (message){
                SchedulerBinding.instance.addPostFrameCallback((_){
                  showSnackber(context: context, content: message);
                });
              }
            ),
            builder: (context, AsyncSnapshot<List<Map<String,dynamic>>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                return Center(child: showCircularProgressIndicator());
              }
              else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No Mess found.'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder:(context, index){
                  bool showmealSessionList = false;
                  return StatefulBuilder(
                    builder: (context, setLocalState){
                      return Card(
                        color: Colors.green.shade100,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Text("${index+1}"),
                              title: Text(
                                "Name: ${snapshot.data![index][Constants.messName]}",
                                style: getTextStyleForTitleL(),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Id: ${snapshot.data![index][Constants.messId]}",
                                    style: getTextStyleForSubTitleL()
                                  ),
                                  Text(
                                    "Joined At: ${DateFormat("hh:mm a dd-MM-yyyy").format(snapshot.data![index][Constants.joindAt].toDate().toLocal())}",
                                    style: getTextStyleForSubTitleM()
                                  ),
                                ],
                              ),
                              trailing: snapshot.data![index][Constants.messId] == authProvider.getUserModel!.currentMessId? Icon(Icons.check):SizedBox.shrink(),
                              onTap: () {
                                setLocalState((){
                                  showmealSessionList = !showmealSessionList;
                                });
                              },
                            ),
                            if(showmealSessionList)Row(
                              mainAxisAlignment:MainAxisAlignment.center,
                              children: [
                                Text(
                                  "The List Of Meal Session",
                                  style: getTextStyleForTitleM(),
                                ),
                                Icon(Icons.arrow_downward)
                              ],
                            ),
                            if(showmealSessionList)FutureBuilder(
                              future: messProvider.getAMemberMealSessionListForASpacificMess(
                                uId: authProvider.getUserModel!.uId, 
                                messId:snapshot.data![index][Constants.messId].toString(),
                                onFail: (message){
                                  SchedulerBinding.instance.addPostFrameCallback((_){
                                    showSnackber(context: context, content: message);
                                  });
                                }
                              ),
                              builder: (context, AsyncSnapshot snapshot2) {
                                if (snapshot2.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                                  return Center(child: showCircularProgressIndicator());
                                }
                                else if (snapshot2.hasError) {
                                  return Center(child: Text('Error: ${snapshot2.error}'));
                                }
                                else if (!snapshot2.hasData || snapshot2.data == null || snapshot2.data!.isEmpty) {
                                  return Center(child: Text('No Data found.'));
                                }
                                return ListView.builder(
                                  itemCount: snapshot2.data.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    MemberSummaryModel memberSummaryModel = MemberSummaryModel.fromMap(snapshot2.data![index] as Map<String,dynamic>);
                                    return Card(
                                      color: Colors.green.shade50,
                                      child: ListTile(
                                        title: Text(
                                          "Meal Session Id: ${memberSummaryModel.mealSessionId}",
                                          style: getTextStyleForTitleS(),
                                        ),
                                        subtitle: Text(
                                          "Joined At: ${DateFormat("hh:mm a dd-MM-yyyy").format(memberSummaryModel.joindAt!.toDate().toLocal())}",
                                          style: getTextStyleForSubTitleM()
                                        ),
                                        trailing: snapshot2.data![index][Constants.mealSessionId] == authProvider.getUserModel!.mealSessionId? Icon(Icons.check):SizedBox.shrink(),
                                        onTap: () {
                                          if(snapshot2.data![index][Constants.mealSessionId] == authProvider.getUserModel!.mealSessionId){
                                            showMessageDialog(context: context, title: "Current Meal Session", Discreption: "This is your current meal session.\nyou will be avail to see this meal details after close this meal session.");
                                            return;
                                          }
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>MemberSummary(memberSummaryModel:memberSummaryModel)));
                                        },
                                      )
                                    );
                                  }
                                );
                              }
                            ),
                          ],
                        ),
                      );
                    }
                  );
                }
              );
            }
          ),
        ),
      ),
    );
  }
}