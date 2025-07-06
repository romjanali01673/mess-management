import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/meal_provider.dart';
import 'package:provider/provider.dart';

class MyMealList extends StatefulWidget {
  final bool fromPreMember;
  final String? messId;
  final String? mealSessionId;
  final String? uId;
  const MyMealList({super.key, this.fromPreMember = false, this.messId, this.mealSessionId, this.uId});

  @override
  State<MyMealList> createState() => _MyMealListState();
}

class _MyMealListState extends State<MyMealList> {
  bool showTotalMeal = false;
  @override
  Widget build(BuildContext context) {
    final mealProvider = context.read<MealProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if(!widget.fromPreMember) StatefulBuilder(
            builder: (context , setLocalState) {
              return  Card(
                color: Colors.green.shade500,
                child: ListTile(
                  trailing: IconButton(
                    onPressed: (){
                      setLocalState(() {
                      showTotalMeal = !showTotalMeal;
                        
                      });
                    }, 
                    icon: showTotalMeal? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                  ),
                  title: 
                  showTotalMeal? 
                  FutureBuilder(
                    future: mealProvider.getTotalMealOfMember(
                      uId: authProvider.getUserModel!.uId,
                      messId: authProvider.getUserModel!.currentMessId,
                      mealSessionId: authProvider.getUserModel!.mealSessionId,
                      onFail: (message){
                        showSnackber(context: context, content: "somthing Wrong! \n$message");
                      }, 
                    ),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                        return Center(child: showCircularProgressIndicator());
                      }
                      else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                      } 
                      else if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No Transaction found.');
                    }
                      return Text("Total Meal: ${mealProvider.getTotalMeal}",);
                    }
                  )
                  :
                  Text("tap to see Meal"),
                ),
              );
            }
          ),
         
          Expanded(
            child: FutureBuilder(
              future: widget.fromPreMember? mealProvider.getAllMealListOfAMember(
                messId: widget.messId!, 
                mealSessionId: widget.mealSessionId!, 
                uId: widget.uId!, 
                onFail: (_){},
              )
              :
              mealProvider.getAllMealListOfAMember(
                messId: authProvider.getUserModel!.currentMessId, 
                mealSessionId: authProvider.getUserModel!.mealSessionId, 
                uId: authProvider.getUserModel!.uId, 
                onFail: (_){},
              ),
              builder: (context, AsyncSnapshot<List<Map<String,dynamic>>?> snapshot) {
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
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final mealData = snapshot.data![index];
                    return StatefulBuilder(
                      builder: (context, setLocalState){
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text("${index+1}"),
                            ),
                            title: Text("Date: "+mealData[Constants.date].toString()),
                            subtitle: Text("Entry Time: "+"${DateFormat("hh:mm a dd-MM-yyyy").format(mealData[Constants.createdAt].toDate().toLocal())}"),
                            trailing: showPrice(value: mealData[Constants.meal].toString()),
                          ),
                        );
                      }
                    );
                  },
                );

              }
            ),
          )
        ],
      ),
    );
  }
}