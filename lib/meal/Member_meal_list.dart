import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/meal_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';

import 'package:provider/provider.dart';

class MemberMealList extends StatefulWidget {
  const MemberMealList({super.key});

  @override
  State<MemberMealList> createState() => _MemberMealListState();
}



class _MemberMealListState extends State<MemberMealList> {
  String userId ="";
  List<Map<String,dynamic>>? memberMealData;

  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Expanded(
      // color: Colors.red,
      // width: double.infinity,
      // height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          getMealList(),
        ],
      ),
    );
  }

  Widget getMealList(){
    final mealProvider = context.read<MealProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    // controller: listOfTexteditingController[index],
                    onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
                    // enabled: member[Constants.status]==Constants.enable,
                    onChanged: (value){
                      userId = value.toString().trim();
                    },
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textInputAction: TextInputAction.done,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder()
                    ),
                  ),
                )
              ),
              ElevatedButton(
                onPressed: ()async{
                  if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                    showSnackber(context: context, content: "Required Administrator Power");
                    return;
                  }
                  memberMealData = null;
                  memberMealData = await mealProvider.getAllMealListOfAMember(
                    messId: authProvider.getUserModel!.currentMessId, 
                    uId: userId, 
                    onFail: (message){showSnackber(context: context, content: "somthing Wrong \n $message");},
                  );
                  if(memberMealData == null) showSnackber(context: context, content: "The Member Meal List Are Empty!");

                  setState(() {
                    
                  });
                }, 
                child: Text("Check"),
              ),
            ],
          ),
          memberMealData!=null?
          
          Expanded(
            child: Column(
              children: [
                Card(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${memberMealData![0][Constants.fname]}"),
                          Text("UId: $userId"),
                          Text("Total Meal: ${mealProvider.getTotalMeal}", style: TextStyle(fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                  )
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: memberMealData!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${memberMealData![index][Constants.date]}"),
                            Text("Entry Time: ${DateFormat("hh:mm a dd-MM-yyyy").format(memberMealData![index][Constants.createdAt].toDate().toLocal())}"),
                           
                          ],
                        ),
                        trailing: Text("${memberMealData![index][Constants.meal]}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      );
                    },
                  )
                ),
              ],
            ),
          )
          :
          SizedBox.shrink(),
        ],
      ),
    );
  }
}