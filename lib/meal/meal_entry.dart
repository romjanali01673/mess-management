import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/meal_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/meal_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MealEntryScreen extends StatefulWidget {
  final MealModel? preMealModel;
  const MealEntryScreen({super.key, this.preMealModel });

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  bool isUpdate = false;
  bool _isDisposed = false;
  DateTime? date;

  var dateController  = TextEditingController();
  List<TextEditingController> listOfTexteditingController=[];
  // [{uid, fname, meal}]
  List<Map<String, dynamic>> listOfMeal=[];
  List<Map<String,dynamic>> memberData =[];

  double getTotalMeal(){
    double totalMeal = 0;
    listOfMeal.map((x){
      totalMeal+= double.parse(x[Constants.meal].toString());
    }).toList();

    return totalMeal;
  }

  setData({required bool isUpdate}){
    if(isUpdate){
      date = DateFormat("dd-MM-yyyy").parse(widget.preMealModel!.date);
      dateController.text = widget.preMealModel!.date;

      memberData = widget.preMealModel!.listOfMeal;           
      // set here the list of meal.
      listOfMeal = List.generate(memberData!.length,(index)=><String,dynamic>{Constants.meal : memberData[index][Constants.meal]});
      listOfTexteditingController = List.generate(memberData!.length, (_) => TextEditingController());
      
      for(int i =0; i<memberData.length; i++){
        listOfTexteditingController[i].text =memberData[i][Constants.meal].toString(); 
      }
      
      setState(() {
        
      });
    }
    else{
      final messProvider  = context.read<MessProvider>();
      if(messProvider.getMessModel != null){
        memberData = messProvider.getMessModel!.messMemberList;           
        // set here the list of meal.
        listOfMeal = List.generate(memberData!.length,(_)=><String,dynamic>{Constants.meal:0});
        listOfTexteditingController = List.generate(memberData!.length, (_) => TextEditingController());
        setState(() {
          
        });
      }
    }
  }

@override
  void initState() {
    // TODO: implement initState
    if(widget.preMealModel==null){
      setData(isUpdate :false);
    }
    else{
      isUpdate = true;
      setData(isUpdate :true);
    }
    super.initState();
  }


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
    final mealProvider  = context.watch<MealProvider>();
    final authProvider  = context.read<AuthenticationProvider>();
    final messProvider  = context.read<MessProvider>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("Add Meal",style: getTextStyleForTitleXL(),),
          backgroundColor: Colors.grey,
        ),
        body: 
        !(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))
        ?
        Center(child: Text("Required Administrator Power"))
        :
        Container(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onTap: () async{
                            if(isUpdate) return;
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
                  
                if(memberData.isEmpty) Expanded(
                  child: Center(
                    child: IconButton(
                      onPressed: (){
                        setData(isUpdate: isUpdate);
                      }, 
                      icon: Icon(Icons.replay_outlined),
                    )
                  )
                ),
                
                StatefulBuilder(
                  builder: (context, setLocalState) {
                  
                return Padding(
                padding: EdgeInsets.all(10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: memberData.length+1,
                    itemBuilder: (context, index){
                                
                      // the button will be shown in last when we reach in last 
                      if(index==memberData.length){
                        return mealProvider.isLoading? showCircularProgressIndicator()
                        :  
                        getMenuItems(
                          label: isUpdate?"Update":"Submit", 
                          ontap: ()async{
                            if(date == null){
                              showSnackber(context: context, content: "Date Was not Selected");
                              return;
                            }                         
                            bool submit = true; //await showConfirmDialog(context: context, title: "Do you want to ${isUpdate? "Update" :"submit"}?");
                            if(submit ?? false){
                              if(isUpdate){
                                // up to dateabase
                                MealModel mealModel = MealModel(
                                  date: widget.preMealModel!.date,
                                  listOfMeal: listOfMeal, 
                                  totalMeal: getTotalMeal(),
                                  CreatedAt: widget.preMealModel!.CreatedAt
                                );
                                
                                print(mealModel.toMap());
                                
                                await mealProvider.updateAMeal(
                                  mealModel: mealModel, 
                                  extraMeal: mealModel.totalMeal - widget.preMealModel!.totalMeal,
                                  messId: authProvider.getUserModel!.currentMessId, 
                                  mealSessionId: authProvider.getUserModel!.mealSessionId, 
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
                                    dateController.clear();
                                    isUpdate = false;
                                    date = null;
                                
                                    showSnackber(context: context, content: "Meal Update Success");
                                    Navigator.pop(context);
                                  }, 
                                );
                              }
                              else{
                                // update to dateabase
                                MealModel mealModel = MealModel(
                                  date: DateFormat("dd-MM-yyyy").format(date!),
                                  listOfMeal: listOfMeal, 
                                  totalMeal: getTotalMeal(),
                                );
                                // print(mealModel.toMap());
                                // print(authProvider.getUserModel!.mealSessionId);
                                await mealProvider.addAMeal(
                                  mealModel: mealModel, 
                                  messId: authProvider.getUserModel!.currentMessId, 
                                  mealSessionId: authProvider.getUserModel!.mealSessionId, 
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
                                    showSnackber(context: context, content: "Meal Add Success");
                                    setLocalState(() {
                                      
                                    });
                                  }
                                );
                                
                              }
                              
                            }
                          }
                        );
                      }
                                
                      final member = memberData[index];
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
                                autofocus: false,
                                controller: listOfTexteditingController[index],
                                // onTapOutside: (event) {// close keyboard
                                //   FocusScope.of(context).unfocus();
                                // },
                                enabled: isUpdate? true :  member[Constants.status]==Constants.enable,
                                onChanged: (value){
                                  value = value.trim();
                                  try{
                                    print(value.toString());
                                    double d = value.isEmpty ? 0 : double.tryParse(value) ?? 0;
                                    listOfMeal[index][Constants.meal] = d;
                                  }catch(e){
                                    listOfTexteditingController[index].text = "";
                                    listOfMeal[index][Constants.meal] = 0;
                                  }
                                  debugPrint(listOfMeal[index].toString());
                                },
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                                textInputAction: index==memberData!.length-1? TextInputAction.done : TextInputAction.next,
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
                },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

