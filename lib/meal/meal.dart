import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/meal/Member_meal_list.dart';
import 'package:meal_hisab/meal/group_meal_list.dart';
import 'package:meal_hisab/meal/meal_entry.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/meal_provider.dart';
import 'package:provider/provider.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  bool showTotalMeal = false;
  Meal mealGroup = Meal.mealList;

  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      // width: double.infinity,
      // height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                getMenuItems(
                  label: "My Meal List", 
                  ontap: (){
                    mealGroup = Meal.mealList;
                    setState(() {
                      
                    });
                  },
                  selected: mealGroup == Meal.mealList,
                  icon: Icons.format_list_numbered_rtl_outlined
                ),
                getMenuItems(
                  label:  "Entry", 
                  ontap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> MealEntryScreen()));
                  },
                  selected: mealGroup == Meal.mealEntry,
                  icon: Icons.create,
                ),
                getMenuItems(
                  label: "Group Meal List", 
                  ontap: (){
                    mealGroup = Meal.groupMealList;
                    setState(() {
                      
                    });
                  },
                  selected: mealGroup == Meal.groupMealList,
                  icon: FontAwesomeIcons.list,
                ),
                getMenuItems(
                  label: "Member Meal List", 
                  ontap: (){
                    mealGroup = Meal.memberMealList;
                    setState(() {
                      
                    });
                  },
                  selected: mealGroup == Meal.memberMealList,
                  icon: Icons.line_weight_sharp,
                ),
              ],
            ),
          ),

          mealGroup == Meal.mealEntry?
          MealEntryScreen()
          :
          mealGroup ==Meal.groupMealList?
          GroupMealList()
          :
          mealGroup ==Meal.memberMealList?
          MemberMealList()
          :
          getMyMealList(),// defalut page or home page

        ],
      ),
    );
  }

  Widget getMyMealList(){
    final mealProvider = context.read<MealProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    return Expanded(
      child: Column(
        children: [
          Card(
            color: Colors.green.shade500,
            child: ListTile(
              trailing: IconButton(
                onPressed: (){
                  setState(() {
                  showTotalMeal = !showTotalMeal;
                    
                  });
                }, 
                icon: showTotalMeal? Icon(Icons.visibility) : Icon(Icons.visibility_off),
              ),
              title: 
              showTotalMeal? 
              FutureBuilder(
                future: mealProvider.getMealList(
                  messId: authProvider.getUserModel!.currentMessId,
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
                      return Center(child: Text('No Transaction found.'));
                }
                  return Text("Total Meal: ${mealProvider.getTotalMeal}",);
                }
              )
              :
              Text("tap to see Meal"),
            ),
          ),
         
          Expanded(
            child: FutureBuilder(
              future: mealProvider.getAllMealListOfAMember(
                messId: authProvider.getUserModel!.currentMessId, 
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
                    return Center(child: Text('No Transaction found.'));
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
                            trailing: Text(mealData[Constants.meal].toString()),
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