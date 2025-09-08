

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/bazer/bazer_list.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/deposit/my_deposit.dart';
import 'package:mess_management/fund/fund.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/meal/my_meal_list.dart';
import 'package:mess_management/model/member_summary_model.dart';
import 'package:mess_management/model/mess_summary_model.dart';
import 'package:mess_management/pre_data/member_summary.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MessSummary extends StatefulWidget{
  final MessSummaryModel messSummaryModel;
  const MessSummary({super.key,required this.messSummaryModel});

  @override
  State<MessSummary> createState()=>_MessSummaryState();
}

class _MessSummaryState extends State<MessSummary>{

  Set<String> optionList={"Deposit", "bazer", "Meal", "Fund",};
  String selectedOption = "";


  @override
  initState(){
    
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
          physics: AlwaysScrollableScrollPhysics(),
          child: widget.messSummaryModel.status!=Constants.Temporary? Column(
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
                                    text: widget.messSummaryModel.messName,
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
                                    text: widget.messSummaryModel.messId,
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
                                    text: widget.messSummaryModel.mealSessionId,
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
                                    text: DateFormat("hh:mm:ss a dd-MM-yyyy").format(widget.messSummaryModel.joindAt!.toDate().toLocal()),
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
                                    text: DateFormat("hh:mm:ss a dd-MM-yyyy").format(widget.messSummaryModel.closedAt!.toDate().toLocal()),
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
                                    text: "Total Deposit: ",
                                    style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: getFormatedPrice(value: widget.messSummaryModel.totalDeposit),
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
                                    text: getFormatedPrice(value: widget.messSummaryModel.remaining),
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
                                    text: getFormatedPrice(value: widget.messSummaryModel.mealRate),
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
                                    text: getFormatedPrice(value: widget.messSummaryModel.totalMealOfMess),
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
                                    text: getFormatedPrice(value: widget.messSummaryModel.totalBazerCost),
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
                                    text: getFormatedPrice(value: widget.messSummaryModel.currentFundBlance),
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
                                    text: widget.messSummaryModel.status,
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
                      "Member Details-",
                      style: getTextStyleForTitleL(),
                    ),

                    // member list 
                    ListView.builder(
                      shrinkWrap: true,
                      physics:NeverScrollableScrollPhysics(),
                      itemCount: widget.messSummaryModel.messMemberList.length,
                      itemBuilder: (context, index){
                        var memberData = widget.messSummaryModel.messMemberList[index];
                        return ListTile(
                          title: Text(
                            memberData[Constants.fname],
                            style: getTextStyleForTitleM(),
                          ),
                          subtitle: Text(
                            memberData[Constants.uId],
                            style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            onPressed: ()async{
                              showSnackber(context: context, content: "Navigating.....");
                              MemberSummaryModel? memberSummaryModel =await messProvider.getAMemberMealSummaryForASpacificMess(
                                uId: memberData[Constants.uId], 
                                messId: widget.messSummaryModel.messId,
                                mealSessionId: widget.messSummaryModel.mealSessionId,
                                onFail: (message){
                                  showSnackber(context: context, content: "Somthing Wrong\nmessage");
                                },
                              );
                              if(memberSummaryModel!=null){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>MemberSummary(memberSummaryModel: memberSummaryModel)));
                              }
                            }, 

                            icon: Icon(Icons.info_outline_rounded),
                          ),
                        );
                      }
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                        
                    //     TextButton(
                    //       onPressed: (){
                    //         selectedOption = optionList.first;
                    //         setState(() {
                              
                    //         });
                    //       }, 
                    //       child: Text(
                    //         "Deposit",
                    //         style: getTextStyleForTitleM(),
                    //       ),
                    //     ),
              
                    //     TextButton(
                    //       onPressed: (){
                    //         selectedOption = optionList.elementAt(1);
                    //         setState(() {
                              
                    //         });
                    //       }, 
                    //       child: Text(
                    //         "Bazer",
                    //         style: getTextStyleForTitleM(),
                    //       ),
                    //     ),
                        
                    //     TextButton(
                    //       onPressed: (){
                    //         selectedOption = optionList.elementAt(2);
                    //         setState(() {
                              
                    //         });
                    //       }, 
                    //       child: Text(
                    //         "Meal",
                    //         style: getTextStyleForTitleM(),
                    //       ),
                    //     ),
                        
                    //     TextButton(
                    //       onPressed: (){
                    //         selectedOption = optionList.elementAt(3);
                    //         setState(() {
        
                    //         });
                    //       }, 
                    //       child: Text(
                    //         "Fund",
                    //         style: getTextStyleForTitleM(),
                    //       ),
                    //     ),
                        
                    //   ],
                    // ),
                  ],
                ),
              ),
              // if(selectedOption=="") Center(
              //   child: Text("Select an options to see it's details"),
              // ),
              // if(selectedOption==optionList.first) SizedBox(
              //   height: 600,
              //   child: Column(
              //     children: [
              //       MyDeposit(
              //         fromPreMember: true, 
              //         messId: widget.messSummaryModel.messId,
              //         mealSessionId: widget.messSummaryModel.mealSessionId,
              //         uId: authProvider.getUserModel!.uId,
              //       ),
              //     ],
              //   )
              // ),
              // if(selectedOption==optionList.elementAt(1)) SizedBox(
              //   height: 600,
              //   child: Column(
              //     children: [
              //       BazerListScreen(
              //         fromPreMember: true, 
              //         messId: widget.messSummaryModel.messId,
              //         mealSessionId: widget.messSummaryModel.mealSessionId,
              //         fromDate:widget.messSummaryModel.joindAt, 
              //         toDate:widget.messSummaryModel.closedAt, 
              //       ),
              //     ],
              //   )
              // ),
              // if(selectedOption==optionList.elementAt(2)) SizedBox(
              //   height: 600,
              //   child: Column(
              //     children: [
              //       MyMealList(
              //         fromPreMember: true, 
              //         messId: widget.messSummaryModel.messId,
              //         mealSessionId: widget.messSummaryModel.mealSessionId,
              //         uId: authProvider.getUserModel!.uId,
              //       ),
              //     ],
              //   )
              // ),
              // if(selectedOption==optionList.elementAt(3)) SizedBox(
              //   height: 600,
              //   child: Column(
              //     children: [
              //       FundHome(
              //         fromPreMember: true, 
              //         messId: widget.messSummaryModel.messId,
              //         fromDate:widget.messSummaryModel.joindAt, 
              //         toDate:widget.messSummaryModel.closedAt, 
              //         // toDate:Timestamp.fromDate(DateTime.now().add(const Duration(days: 90)))
              //       ),
              //     ],
              //   )
              // )
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
                    if(widget.messSummaryModel.messId != authProvider.getUserModel!.currentMessId){
                      showMessageDialog(
                        context: context, 
                        title: "Info", 
                        Discreption: "you are not in the mess. that's why you can't genarate your \"summary\". please wait until menager close meal session.",
                      );
                    }
                    else{
                      // genarate member summary
                      await messProvider.genarateMemberSummary(
                        messSummaryModel: widget.messSummaryModel,
                        onFail: (message) {
                          showSnackber(context: context, content: "failed");
                        },
                        onSuccess: () {
                          
                          showSnackber(context: context, content: "successed");
                          authProvider.getUserProfileData(onFail: (_){});
                          Navigator.pop(context);
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