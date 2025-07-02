

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/bazer/bazer_list.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/deposit/my_deposit.dart';
import 'package:meal_hisab/fund/fund.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/meal/my_meal_list.dart';
import 'package:meal_hisab/model/member_summary_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class Options extends StatefulWidget{
  final MemberSummaryModel memberSummaryModel;
  const Options({super.key,required this.memberSummaryModel});

  @override
  State<Options> createState()=>_OptionsState();
}

class _OptionsState extends State<Options>{

  Set<String> optionList={"Deposit", "bazer", "Meal", "Fund",};
  String selectedOption = "";
  bool found = true;


  @override
  initState(){
    if(widget.memberSummaryModel.status == Constants.Temporary){
      found = false;
    }
    
    super.initState();
  }

  Widget build(BuildContext context){
    final authProvider = context.read<AuthenticationProvider>(); 
    final messProvider = context.read<MessProvider>(); 
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "The Meal Summary",
          style: getTextStyleForTitleXL(),
        ),
        backgroundColor: Colors.grey,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child:found?  Column(
            children: [
              Card(
                color: Colors.grey.shade50,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        // if not found, show a button what represt until did not genarate any summary regenarate.
        
                        
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            // rich text work like a parentTextStyle.copyWith(), mean if use color in child, other all proparty will be same excipt color,
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Mess Name: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.memberSummaryModel.messName,
                                  ),
                                ]
                              )
                            ),
                            
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Mess Id: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.memberSummaryModel.messId,
                                  ),
                                ]
                              )
                            ),
                            
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Meal Session Id: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.memberSummaryModel.mealSessionId,
                                  ),
                                ]
                              )
                            ),
                            
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Joined At: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: DateFormat("hh:mm:ss a dd-MM-yyyy").format(widget.memberSummaryModel.joindAt!.toDate().toLocal()),
                                  ),
                                ]
                              )
                            ),
                            
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Closed At: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: DateFormat("hh:mm:ss a dd-MM-yyyy").format(widget.memberSummaryModel.closedAt!.toDate().toLocal()),
                                  ),
                                ]
                              )
                            ),
        
                           
                            
                            SizedBox(
                              height: 20,
                            ),
        
        
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Total Meal: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.memberSummaryModel.totalMeal),
                                  ),
                                ]
                              )
                            ),
                            
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Total Deposit: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.memberSummaryModel.totalDeposit),
                                  ),
                                ]
                              )
                            ),
                            
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Remaining (was): ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.memberSummaryModel.remaining),
                                  ),
                                ]
                              )
                            ),
                            
                            SizedBox(
                              height: 20,
                            ),
                            
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Meal Rate: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.memberSummaryModel.mealRate),
                                  ),
                                ]
                              )
                            ),
        
        
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Total Meal: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.memberSummaryModel.totalMealOfMess),
                                  ),
                                ]
                              )
                            ),
        
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Total Bazer Cost: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.memberSummaryModel.totalBazerCost),
                                  ),
                                ]
                              )
                            ),
        
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Fand Blance (was): ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.memberSummaryModel.currentFundBlance),
                                  ),
                                ]
                              )
                            ),
        
                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "Status: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.memberSummaryModel.status,
                                  ),
                                ]
                              )
                            ),
                            
                            
                          ],
                        )
                        
        
                      ),
                    ),
                    // for details
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Show Details-",
                      style: getTextStyleForTitleL(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        
                        TextButton(
                          onPressed: (){
                            selectedOption = optionList.first;
                            setState(() {
                              
                            });
                          }, 
                          child: Text(
                            "Deposit",
                            style: getTextStyleForTitleM(),
                          ),
                        ),
              
                        TextButton(
                          onPressed: (){
                            selectedOption = optionList.elementAt(1);
                            setState(() {
                              
                            });
                          }, 
                          child: Text(
                            "Bazer",
                            style: getTextStyleForTitleM(),
                          ),
                        ),
                        
                        TextButton(
                          onPressed: (){
                            selectedOption = optionList.elementAt(2);
                            setState(() {
                              
                            });
                          }, 
                          child: Text(
                            "Meal",
                            style: getTextStyleForTitleM(),
                          ),
                        ),
                        
                        TextButton(
                          onPressed: (){
                            selectedOption = optionList.elementAt(3);
                            setState(() {
        
                            });
                          }, 
                          child: Text(
                            "Fund",
                            style: getTextStyleForTitleM(),
                          ),
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),
              if(selectedOption=="") Center(
                child: Text("Select an options to see it's details"),
              ),
              if(selectedOption==optionList.first) SizedBox(
                height: 600,
                child: Column(
                  children: [
                    MyDeposit(
                      fromPreMember: true, 
                      messId: widget.memberSummaryModel.messId,
                      mealSessionId: widget.memberSummaryModel.mealSessionId,
                      uId: authProvider.getUserModel!.uId,
                    ),
                  ],
                )
              ),
              if(selectedOption==optionList.elementAt(1)) SizedBox(
                height: 600,
                child: Column(
                  children: [
                    BazerListScreen(
                      fromPreMember: true, 
                      messId: widget.memberSummaryModel.messId,
                      mealSessionId: widget.memberSummaryModel.mealSessionId,
                      fromDate:widget.memberSummaryModel.joindAt, 
                      toDate:widget.memberSummaryModel.closedAt, 
                    ),
                  ],
                )
              ),
              if(selectedOption==optionList.elementAt(2)) SizedBox(
                height: 600,
                child: Column(
                  children: [
                    MyMealList(
                      fromPreMember: true, 
                      messId: widget.memberSummaryModel.messId,
                      mealSessionId: widget.memberSummaryModel.mealSessionId,
                      uId: authProvider.getUserModel!.uId,
                    ),
                  ],
                )
              ),
              if(selectedOption==optionList.elementAt(3)) SizedBox(
                height: 600,
                child: Column(
                  children: [
                    FundHome(
                      fromPreMember: true, 
                      messId: widget.memberSummaryModel.messId,
                      fromDate:widget.memberSummaryModel.joindAt, 
                      toDate:widget.memberSummaryModel.closedAt, 
                      // toDate:Timestamp.fromDate(DateTime.now().add(const Duration(days: 90)))
                    ),
                  ],
                )
              )
            ],
          )
          :   
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                ),
                ElevatedButton(
                  onPressed: ()async{
                    if(widget.memberSummaryModel.messId != authProvider.getUserModel!.currentMessId){
                      showMessageDialog(
                        context: context, 
                        title: "Info", 
                        Discreption: "you are not in the mess. that's why you can't genarate your \"summary\". please wait until menager close meal session.",
                      );
                    }
                    else{
                      // genarate member summary
                      await messProvider.genarateMemberSummary(
                        uId: authProvider.getUserModel!.uId,
                        memberSummaryModel: widget.memberSummaryModel,
                        onFail: (message) {
                          showSnackber(context: context, content: "failed");
                        },
                        onSuccess: () {
                          showSnackber(context: context, content: "successed");
                          authProvider.getUserProfileData(onFail: (_){});
                        },
                      );
                    }
                  }, 
                  child: Text("Genarate"),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Your meal summary hasn't genarate yet.\n Click to the genarate button to genarate your meal summary.",
                  textAlign: TextAlign.center,  
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}