

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/bazer/bazer_list.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/deposit/my_deposit.dart';
import 'package:mess_management/fund/fand_list.dart';
import 'package:mess_management/fund/fund.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/meal/my_meal_list.dart';
import 'package:mess_management/model/member_summary_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MemberSummary extends StatefulWidget{
  final MemberSummaryModel memberSummaryModel;
  const MemberSummary({super.key,required this.memberSummaryModel});

  @override
  State<MemberSummary> createState()=>_MemberSummaryState();
}

class _MemberSummaryState extends State<MemberSummary>{

  Set<String> optionList={"Deposit", "bazer", "Meal", "Fund",};
  String selectedOption = "";


  @override
  initState(){
    super.initState();
  }

  Widget build(BuildContext context){
    // final authProvider = context.read<AuthenticationProvider>(); 
    // final messProvider = context.read<MessProvider>(); 
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "The Meal Summary",
          style: getTextStyleForTitleXL(),
        ),
        backgroundColor: Colors.grey,
      ),
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled){
            return [
              SliverToBoxAdapter(
                child: Card(
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
                                    text: "Full Name: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.memberSummaryModel.fname,
                                  ),
                                ]
                              )
                            ),

                            Text.rich(
                              TextSpan(
                                style: getTextStyleForSubTitleXL(), 
                                children: [
                                  TextSpan(
                                    text: "User Id: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.memberSummaryModel.uId,
                                  ),
                                ]
                              )
                            ),

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
                                    text: "Total Meal Of Mess: ",
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
              ),
            ];
          },
          body: selectedOption==""? Center(
            child: Text("Select an options to see it's details"),
          )
          :
          (selectedOption==optionList.first)? MyDeposit(
            fromPreMember: true, 
            messId: widget.memberSummaryModel.messId,
            mealSessionId: widget.memberSummaryModel.mealSessionId,
            uId: widget.memberSummaryModel.uId,
          )
          :
          (selectedOption==optionList.elementAt(1))? BazerListScreen(
            fromPreMember: true, 
            messId: widget.memberSummaryModel.messId,
            mealSessionId: widget.memberSummaryModel.mealSessionId,
            fromDate:widget.memberSummaryModel.joindAt, 
            toDate:widget.memberSummaryModel.closedAt, 
          )
          :
          (selectedOption==optionList.elementAt(2))? MyMealList(
            fromPreMember: true, 
            messId: widget.memberSummaryModel.messId,
            mealSessionId: widget.memberSummaryModel.mealSessionId,
            uId: widget.memberSummaryModel.uId,
          )
          :
          FundList(
            fromPreMember: true, 
            messId: widget.memberSummaryModel.messId,
            fromDate:widget.memberSummaryModel.joindAt, 
            toDate:widget.memberSummaryModel.closedAt, 
            // toDate:Timestamp.fromDate(DateTime.now().add(const Duration(days: 90)))
          )
        )
        
        
        
        
      ),
    );
  }
}