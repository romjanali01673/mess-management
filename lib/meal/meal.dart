import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/meal/group_meal_list.dart';
import 'package:meal_hisab/meal/meal_entry.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  Meal mealGroup = Meal.mealList;
  int year = DateTime.now().year;
  TextEditingController dateController = TextEditingController(text: DateTime.now().year.toString());
  List<Map<String, List>> month = [
    
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
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
              ],
            ),
          ),

          mealGroup == Meal.mealEntry?
          MealEntryScreen()
          :
          mealGroup ==Meal.groupMealList?
          GroupMealList()
          :
          getMealList(),// defalut page or home page

        ],
      ),
    );
  }

  Widget getMealList(){
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black
                  ),
                  children: [
                    TextSpan(text: "Select Another Year As Need: "),
                    TextSpan(text: ""),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onTap: () async{
                      DateTime? date = await showDatePicker(
                        // fieldHintText: "mm/dd/YYYY",
                        fieldLabelText: "mm/dd/YYYY", // defalut "Enter Date"
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate : DateTime(2000,12,30,12,59,59),
                        lastDate: DateTime(2150),
                        initialDatePickerMode: DatePickerMode.year,
                        initialEntryMode:DatePickerEntryMode.calendar,
                        // helpText: "Set Date", // default "Select date"
                      );
                      if(date!=null){
                        setState(() {
                          
                        });
                        year = date.year;
                        dateController.text = year.toString();
                      }
                    },
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        
                      ),
                      label: Text("Select Year"),
                      hintText: "Select date",
                          
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: month.asMap().entries.map((val){
                int index = val.key;
                Map<String, List> monthName = val.value;
                
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        
                        onTap: () {
                          monthName[monthName.keys.first]![0] = !monthName[monthName.keys.first]![0];
                          setState(() {
                            
                          });
                          if(monthName[monthName.keys.first]![0]){
                            debugPrint("Hello romjan how are you?");
                          }
                          else{
                            debugPrint("Hello romjan how are you?-----");
                      
                          }
                        },
                        title: Text("${monthName.keys}"),
                        subtitle: Text("$year"),
                        leading: CircleAvatar(
                          child: Text("${index+1}"),
                        ),
                        trailing: monthName[monthName.keys.first]![0] ? Icon(Icons.arrow_drop_down_rounded) : Icon(Icons.arrow_right),
                      ),
                      if(monthName[monthName.keys.first]![0])...[
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am bjgj jjkjhkh kjhkhkhkkj kh  a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                        Text("hello md romjan ali i am a student i want to be your gf."),
                      ]
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }


}