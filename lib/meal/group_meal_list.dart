import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/meal/meal_entry.dart';
import 'package:mess_management/model/meal_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/meal_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class GroupMealList extends StatefulWidget {
  const GroupMealList({super.key});

  @override
  State<GroupMealList> createState() => _GroupMealListState();
}



class _GroupMealListState extends State<GroupMealList> {
  bool showTotalMeal = false;
  int year = DateTime.now().year;
  TextEditingController dateController = TextEditingController(text: DateTime.now().year.toString());
  List<Map<String, List>> month = [
    
    {"January"   : [false, "January",1]},
    {"February"  : [false, "February",2]},
    {"March"     : [false, "March",3]},
    {"April"     : [false, "April",4]},
    {"May"       : [false, "May",5]},
    {"June"      : [false, "June",6]},
    {"July"      : [false, "July",7]},
    {"August"    : [false, "August",8]},
    {"September" : [false, "September",9]},
    {"October"   : [false, "October",10]},
    {"November"  : [false, "November",11]},
    {"December"  : [false, "December",12]},
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
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    
    return Expanded(
      // color: Colors.red,
      // width: double.infinity,
      // height: double.infinity,
      child: 
      !(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))
      ?
      Center(child: Text("Required Administrator Power"))
      :
      Column(
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

    return Expanded(
      child: Column(
        children: [
          StatefulBuilder(
            builder: (context, setLocalState) {
              return Card(
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
                    future: mealProvider.getTotalMealOfMessFromDatabase(
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
                      return Text("Total Mess Meal: ${mealProvider.getTotalMealOfMess}",);
                    }
                  )
                  :
                  Text("tap to see Meal"),
                ),
              );
            }
          ),
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
                        fieldHintText: "mm/dd/YYYY",
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
                int days = getDaysInMonth(year,monthName[monthName.keys.first]![2]);
                debugPrint(monthName[monthName.keys.first]![2].toString()+"-"+days.toString());
                
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
                        title: Text("${monthName[monthName.keys.first]![1]}"),
                        subtitle: Text("$year"),
                        leading: CircleAvatar(
                          child: Text("${index+1}"),
                        ),
                        trailing: monthName[monthName.keys.first]![0] ? Icon(Icons.arrow_drop_down_rounded) : Icon(Icons.arrow_right),
                      ),
                      if(monthName[monthName.keys.first]![0]) ...List.generate(
                        days, (x){
                          x++;
                          bool canSee = false;
                          return StatefulBuilder(
                            builder: ( context,setLocalState){
                              return Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.only(left: 8),
                                      title: Text("${x}-${monthName[monthName.keys.first]![1]}"),
                                      onTap: () {
                                        canSee = !canSee;
                                        setLocalState(() {
                                          
                                        });
                                      },
                                    ),
                                    if(canSee)...[
                                      FutureBuilder(
                                        future: mealProvider.checkMealModelAlreadyExist(
                                          messId: authProvider.getUserModel!.currentMessId, 
                                          mealSessionId: authProvider.getUserModel!.mealSessionId, 
                                          date: "${x<10?"0$x":x}-${monthName[monthName.keys.first]![2]<10?"0${monthName[monthName.keys.first]![2]}":monthName[monthName.keys.first]![2]}-$year", 
                                          onFail: (message){
                                            showSnackber(context: context, content: "somthing Wrong \n $message");
                                          },
                                        ), 
                                        builder: (context, AsyncSnapshot<MealModel?> snapshot){
                                          if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                                            return Center(child: showCircularProgressIndicator());
                                          }
                                          else if (snapshot.hasError) {
                                            return Center(child: Text('Error: ${snapshot.error}'));
                                          } 
                                          else if (!snapshot.hasData || snapshot.data == null) {
                                            return Center(child: Text('No Transaction found.'));
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    padding: EdgeInsets.all(0),
                                                    onPressed: ()async{
                                                      await Navigator.push(context, MaterialPageRoute(builder: (context)=> MealEntryScreen(preMealModel: snapshot.data,)));
                                                      setLocalState(() {
                                                        
                                                      },);
                                                    }, 
                                                    color: Colors.green.shade500,
                                                    icon:Icon(Icons.edit),
                                                  ),

                                                  IconButton(
                                                    padding: EdgeInsets.all(0),
                                                    onPressed: ()async{
                                                      bool res = await showConfirmDialog(context: context, title: "Do you want to Delete?");
                                                      if(res){
                                                        await mealProvider.deleteAMeal(
                                                          date: "${x<10?"0$x":x}-${monthName[monthName.keys.first]![2]<10?"0${monthName[monthName.keys.first]![2]}":monthName[monthName.keys.first]![2]}-$year", 
                                                          onFail: (message){
                                                            showSnackber(context: context, content: "Deletein Failed!\n$message");
                                                          }, 
                                                          onSuccess: () {
                                                            showSnackber(context: context, content: "Deletein Successed.");
                                                            setLocalState((){

                                                            });
                                                          },
                                                          messId: authProvider.getUserModel!.currentMessId, 
                                                          mealSessionId: authProvider.getUserModel!.mealSessionId, 
                                                          extraMeal: (- snapshot.data!.totalMeal),
                                                        );
                                                      }
                                                    }, 
                                                    color: Colors.red.shade400,
                                                    icon:Icon(Icons.delete),
                                                  ),
                                                ],
                                              ),
                                              ...List.generate(snapshot.data!.listOfMeal.length, (no){
                                                return ListTile(
                                                  leading: Text("${no+1}"),
                                                  title: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(" Name: " + snapshot.data!.listOfMeal[no][Constants.fname].toString()),
                                                      Text(" UId: " + snapshot.data!.listOfMeal[no][Constants.uId].toString()),
                                                      Text(" Meal : " + snapshot.data!.listOfMeal[no][Constants.meal].toString()),
                                                    ],
                                                  ),
                                                );
                                              }),
                                              Text(" Total Meal: "+ snapshot.data!.totalMeal.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(" Meal Day: "+snapshot.data!.date.toString()),
                                              Text(" Entry Time: "+ "${DateFormat("hh:mm a dd-MM-yyyy").format(snapshot.data!.CreatedAt!.toDate().toLocal())}"),
                                              SizedBox(height: 5,),
                                            ],
                                          );
                                        },
                                      ),
                                    ]
                                  ],
                                ),
                              );
                            },
                          );
                        }    
                      ),
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