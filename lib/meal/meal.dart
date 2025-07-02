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
import 'package:meal_hisab/meal/my_meal_list.dart';
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
          MyMealList(),// defalut page or home page

        ],
      ),
    );
  }

  
}