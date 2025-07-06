import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/mess_summary_model.dart';
import 'package:mess_management/pre_data/mess_summary.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MealSessionList extends StatefulWidget {
  const MealSessionList({super.key});

  @override
  State<MealSessionList> createState() => _MealSessionListState();
}

class _MealSessionListState extends State<MealSessionList> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    // final authProvider = context.read<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Meal Session List"),
        backgroundColor: Colors.grey,
      ),
      body: amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider)? RefreshIndicator(
        onRefresh: () async{
          // await Future.delayed(Duration(seconds: 1));
          setState(() {
            
          });
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              FutureBuilder(
                future: messProvider.getAllMessSummaryModelForASpacificMess(
                  messId: authProvider.getUserModel!.currentMessId, 
                  onFail: (_) {}
                ), 
                builder: (context, AsyncSnapshot snapshot){
                  if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                    return Center(child: showCircularProgressIndicator());
                  }
                  else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } 
                  else if (!snapshot.hasData || snapshot.data == null || snapshot.data.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text('No Session found.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context,index){
                      MessSummaryModel messSummaryModel = MessSummaryModel.fromMap(snapshot.data![index] as Map<String,dynamic>);
                      return Card(
                        color: Colors.green.shade50,
                        child: ListTile(
                          title: Text(
                            "Meal Session Id: ${messSummaryModel.mealSessionId}",
                            style: getTextStyleForTitleS(),
                          ),
                          subtitle: Text(
                            "Joined At: ${DateFormat("hh:mm a dd-MM-yyyy").format(messSummaryModel.joindAt!.toDate().toLocal())}",
                            style: getTextStyleForSubTitleM()
                          ),
                          trailing: snapshot.data![index][Constants.mealSessionId] == authProvider.getUserModel!.mealSessionId? Icon(Icons.check):SizedBox.shrink(),
                          onTap: () {
                            if(snapshot.data![index][Constants.mealSessionId] == authProvider.getUserModel!.mealSessionId){
                              showMessageDialog(context: context, title: "Current Meal Session", Discreption: "This is your current meal session.\nyou will be avail to see this meal details after close this meal session.");
                              return;
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>MessSummary(messSummaryModel:messSummaryModel)));
                          },
                        )
                      );
                    }
                  );
                },
              )
            ],
          ),
        ),
      )
      :
      Center(
        child: Text("Required Administrator Power!"),
      )
    );
  }
}