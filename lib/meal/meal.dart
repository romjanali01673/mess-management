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
import 'package:meal_hisab/model/meal_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/meal_provaider.dart';
import 'package:provider/provider.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  bool showTotalMeal = false;
  Meal mealGroup = Meal.mealList;
  int year = DateTime.now().year;
  TextEditingController dateController = TextEditingController(text: DateTime.now().year.toString());
  List<Map<String, List>> month = [
    
    {"January" : [false, "January",1]},
    {"January" : [false, "January",2]},
    {"January" : [false, "January",3]},
    {"January" : [false, "January",4]},
    {"January" : [false, "January",5]},
    {"January" : [false, "January",6]},
    {"January" : [false, "January",7]},
    {"January" : [false, "January",8]},
    {"January" : [false, "January",9]},
    {"January" : [false, "January",10]},
    {"January" : [false, "January",11]},
    {"January" : [false, "January",12]},
    //  "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ];

  @override
  void dispose() {

    dateController.dispose();
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
                  label: "Meal List", 
                  ontap: (){
                    mealGroup = Meal.mealList;
                    setState(() {
                      
                    });
                  },
                  selected: mealGroup == Meal.mealList,
                  icon: FontAwesomeIcons.list
                ),
                getMenuItems(
                  label: "Meal Entry", 
                  ontap: (){
                    mealGroup = Meal.mealEntry;
                    setState(() {
                      
                    });
                  },
                  selected: mealGroup == Meal.mealEntry,
                  icon: Icons.add,
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
                  icon: FontAwesomeIcons.list,
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
          getMealList(),// defalut page or home page

        ],
      ),
    );
  }

  Widget getMealList(){
    final mealProvaider = context.read<MealProvaider>();
    final authProvaider = context.read<AuthenticationProvider>();

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
                icon: showTotalMeal? Icon(Icons.remove_red_eye_sharp) : Icon(Icons.remove_red_eye_outlined),
              ),
              title: 
              showTotalMeal? 
              FutureBuilder(
                future: mealProvaider.getMealList(
                  messId: authProvaider.getUserModel!.currentMessId,
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
                  return Text("Total Meal: ${mealProvaider.getTotalMeal}",);
                }
              )
              :
              Text("tap to see Meal"),
            ),
          ),
         
          Expanded(
            child: FutureBuilder(
              future: mealProvaider.getAllMealListOfAMember(
                messId: authProvaider.getUserModel!.currentMessId, 
                uId: authProvaider.getUserModel!.uId, 
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