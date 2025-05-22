import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/constants.dart';

class GroupMealList extends StatefulWidget {
  const GroupMealList({super.key});

  @override
  State<GroupMealList> createState() => _GroupMealListState();
}

bool leapYear(int year){
  if(year % 4==0){ // if the yaer divisible by 4 that's mean it's can be leap year
    if(year%100==0){ // if the year divisible by 100. it's should be divisible by 400 other wise it's not leep year.
      return year%400==0;
    }
    // if the year are not divisible by 100 it's leep year.
    return true;
  }
  return false;
}


class _GroupMealListState extends State<GroupMealList> {
  int year = DateTime.now().year;
  TextEditingController dateController = TextEditingController(text: DateTime.now().year.toString());
  List<Map<String, List>> month = [
    
    {"January" : [false, "January", 31]},
    {"February" : [false, "February", 28]},
    {"March" : [false, "March", 31]},
    {"January" : [false, "April", 30]},
    {"January" : [false, "May", 31]},
    {"January" : [false, "January", 30]},
    {"January" : [false, "January", 31]},
    {"January" : [false, "January", 31]},
    {"January" : [false, "January", 30]},
    {"January" : [false, "January", 31]},
    {"January" : [false, "January", 30]},
    {"January" : [false, "January", 31]},
    //  "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ];
  List<Map<String, List>> monthDay = [
    
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
                      if(monthName[monthName.keys.first]![0])...[ // if user has clicked in this row either show the data of this row and close
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            // here nexted listview. because we can't use nexted listview with out fixed sized that's why we have to use this method for unfixed size. 
                            children: List.generate(monthName[monthName.keys.first]![2], (index) {//(length,(index){})
                              return Column(
                                children: [
                                  ListTile(
                                    title: ListTile(
                                      onTap: () {
                                        
                                      },
                                      title: Text("Day ${index+1}"),
                                    ),
                                  ),
                                  Column(
                                    children: List.generate(monthName[monthName.keys.first]![2], (index) {
                                      return Text("romjan-3");
                                      
                                    })
                                  )
                                ],
                              );
                            }),
                          ),
                        ),
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