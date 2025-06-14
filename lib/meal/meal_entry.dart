import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/meal_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/meal_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class MealEntryScreen extends StatefulWidget {
  const MealEntryScreen({super.key});

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  bool _isDisposed = false;
  DateTime? date;
  double totalMeal = 0.0;

  var dateController  = TextEditingController();
  late List<TextEditingController> listOfTexteditingController;
  late List<Map<String, dynamic>> listOfMeal;

  @override
  void dispose() {
    // TODO: implement dispose
    _isDisposed = true;
    dateController.dispose();
    listOfTexteditingController.clear();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final mealProvaider  = context.watch<MealProvaider>();
    final messProvaider  = context.read<MessProvaider>();
    final authProvaider  = context.watch<AuthenticationProvider>();

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onTap: () async{
                      date = await showDatePicker(
                        // fieldHintText: "mm/dd/YYYY",
                        fieldLabelText: "Enter Date (DD-MM-YYYY)", // defalut "Enter Date"
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate : DateTime(2000,12,30,12,59,59),
                        lastDate: DateTime(2050),
                        initialDatePickerMode: DatePickerMode.day,
                        initialEntryMode:DatePickerEntryMode.calendar,
                        // helpText: "Set Date", // default "Select date"
                      );
                      if(date!=null){
                        dateController.text = DateFormat("dd-MM-yyyy").format(date!);
                      }
                    },
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        
                      ),
                      label: Text("Date(dd-MM-yyyy)"),
                      hintText: "Select date",
      
                    ),
                  ),
                ),
              ]
            )
          ),
          Expanded(
            child: FutureBuilder(
              future:messProvaider.getMessData(
                onFail: (message) { 
                  showSnackber(context: context, content: message);
                },
                messId: authProvaider.getUserModel!.currentMessId,
                isDisposed: ()=> _isDisposed,
                onSuccess: (){
                  debugPrint("get mess data successfull.");
                },
              ),
              builder: (context, AsyncSnapshot snapshot){
              if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's save 
                return Center(child: CircularProgressIndicator());
              }
              
              else if (messProvaider.getMessModel==null ||messProvaider.getMessModel!.messMemberList.isEmpty ) {
                return Center(child: Text('No member found.'));
              }

              List data = messProvaider.getMessModel!.messMemberList;

                
              // // set here the list of meal.
              listOfMeal = List.generate(data!.length,(_)=><String,dynamic>{Constants.meal:0});
              listOfTexteditingController = List.generate(data!.length, (_) => TextEditingController());

              return StatefulBuilder(
                builder: (context, setLocalState) {
                
              return Padding(
              padding: EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: data!.length+1,
                  itemBuilder: (context, index){

                    // the button will be shown in last when we reach in last 
                    if(index==data.length){
                      return  getMenuItems(
                        label: "submit", 
                        ontap: ()async{
                          if(date == null){
                            showSnackber(context: context, content: "Date Was not Selected");
                            return;
                          }
                          MealModel? m;
                          bool failed = false;
                          m = await mealProvaider.checkMealModelExist(
                            messId: authProvaider.getUserModel!.currentMessId, 
                            date: DateFormat("dd-MM-yyyy").format(date!), 
                            onFail: (message){
                              showSnackber(context: context, content: message);
                              failed = true;                              
                            },
                            onSuccess: (){
                              debugPrint("success");
                            }
                          );
                          if(failed){
                            return;
                          }

                          if(m!=null){
                            showSnackber(context: context, content: "Already Exist in the given date");
                            return;
                          }
                          bool submit = await showConfirmDialog(context: context, title: "Do you want to submit?");
                          if(submit ?? false){
                            // up to dateabase
                            MealModel mealModel = MealModel(
                              date: DateFormat("dd-MM-yyyy").format(date!),
                              listOfMeal: listOfMeal, 
                              totalMeal: totalMeal,
                            );
                            print(mealModel.toMap());

                            mealProvaider.addAMeal(
                              mealModel: mealModel, 
                              messId: authProvaider.getUserModel!.currentMessId, 
                              onFail: (message){
                                showSnackber(context: context, content: message);
                              },
                              onSuccess: (){
                                //al done, clear all
                                listOfMeal.forEach((x){
                                  x[Constants.meal] = 0;
                                });
                                listOfTexteditingController.forEach((x){
                                  x.text = "";
                                });
                                totalMeal = 0;

                                showSnackber(context: context, content: "Meal Add Success");
                                setLocalState(() {
                                  
                                });
                              }
                            );
                          }
                        }
                      );
                    }

                    final member = data[index];
                    listOfMeal[index][Constants.uId] = member[Constants.uId];
                    listOfMeal[index][Constants.fname] = member[Constants.fname];
                    // listOfTexteditingController[index].text = listOfMeal[index].toString();
                   
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Text("${index+1}", style: TextStyle(color: Colors.red, fontSize: 20),),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${member[Constants.fname]}"),
                                Text("${member[Constants.uId]}"),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: listOfTexteditingController[index],
                              onTapOutside: (event) {// close keyboard
                                FocusScope.of(context).unfocus();
                              },
                              enabled: member[Constants.status]==Constants.enable,
                              onChanged: (value){
                                try{
                                  double d = double.parse(value.toString());
                                  listOfMeal[index][Constants.meal] = d;
                                  totalMeal = 0;
                                  listOfMeal.forEach((x){
                                    totalMeal += x[Constants.meal];
                                  });
                                }catch(e){
                                  listOfTexteditingController[index].text = "";
                                  listOfMeal[index][Constants.meal] = 0;
                                  totalMeal = 0;
                                  listOfMeal.forEach((x){
                                    totalMeal += x[Constants.meal];
                                  });
                                }
                                debugPrint(listOfMeal[index].toString());
                              },
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              textInputAction: index==data!.length-1? TextInputAction.done : TextInputAction.next,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder()
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                ),
              );
              },);
              },
            ),
          ),
        ],
      ),
    );
  }
}

