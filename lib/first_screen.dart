import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/notice_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/firstScreen_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}



class _FirstScreenState extends State<FirstScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData()async{
    await Future.delayed(Duration(milliseconds: 50));
    print("A");
    // while(true){
    //   if(!mounted){
    //     break;
    //   }
    //   print("hold");
    // }
    final firstScreenProvider = context.read<FirstScreenProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();

    
    firstScreenProvider.getFundBlance(messId: authProvider.getUserModel!.currentMessId, onFail: (_){});
    firstScreenProvider.getTotalMeal(messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, mealSessionId: authProvider.getUserModel!.mealSessionId);
    firstScreenProvider.getTotalBazer(messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, mealSessionId:  authProvider.getUserModel!.mealSessionId);
    firstScreenProvider.getTotalDeposit(messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, mealSessionId:  authProvider.getUserModel!.mealSessionId);
    firstScreenProvider.getTotalDepositOfMember(uId: authProvider.getUserModel!.uId, messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, mealSessionId:  authProvider.getUserModel!.mealSessionId, );
    firstScreenProvider.getTotalMealOfMember(uId: authProvider.getUserModel!.uId, messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, mealSessionId:  authProvider.getUserModel!.mealSessionId, );
    firstScreenProvider.getPindNoticeForHomeFromDatabase( messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, );
  
    //
    messProvider.listenToMess(messId: authProvider.getUserModel!.currentMessId);
    authProvider.listenMyProfile(uId: authProvider.getUserModel!.uId);
  }

  @override
  Widget build(BuildContext context) {
    final firstScreenProvider = context.watch<FirstScreenProvider>();
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    return Container(  // home Screen
        height: double.infinity,
        width: double.infinity,
        color: Colors.green.shade100,
            child: RefreshIndicator(
              onRefresh: ()async {
                loadData();
                int retries = 0;
                while(true && retries>20){
                  retries++;
                  if(firstScreenProvider.getIsLoading) {
                    await Future.delayed(Duration(seconds: 1));
                  } 
                  else {
                    break;
                  }
                  if(retries>20){
                    showSnackber(context: context, content: "Time Out");
                  }
                }
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    FadeInUp(duration: Duration(milliseconds:100),
                      child: Text("Welcome Back", style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.red.shade800),),
                    ),
              
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      childAspectRatio: .9,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      children: [
                        // menager see
                        if(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))
                        ...[
                            SizedBox(
                              height: 150,
                              child: Card(
                                color: Colors.white70,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      FaIcon(FontAwesomeIcons.bangladeshiTakaSign , size: 15,),
                                      FittedBox( 
                                        child: Text(getFormatedPrice(value: firstScreenProvider.getBlance), style: getTextStyleForTitleM()),
                                                
                                      ),
                                      AutoSizeText(
                                        "Blance",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                            height: 150,
                            child: Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    FaIcon(FontAwesomeIcons.bangladeshiTakaSign , size: 15,),
                                    FittedBox( 
                                      child: Text(getFormatedPrice(value: firstScreenProvider.getTotalDepositOfMess), style: getTextStyleForTitleM()),
                                              
                                    ),
                                    AutoSizeText(
                                      "Total Deposit Of Mess",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      minFontSize: 10,
                                    ),
                                    // Text("Total Deposit Of Mess",style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,maxLines: 2,  textScaler: TextScaler.linear(0.8),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
              
                        SizedBox(
                          height: 150,
                          child: GestureDetector(
                            child: Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      FaIcon(FontAwesomeIcons.bangladeshiTakaSign ,size: 15,),
                                      FittedBox( 
                                        child: Text(getFormatedPrice(value: firstScreenProvider.getMealRate), style: getTextStyleForTitleM()),
                                          
                                      ),
                                      AutoSizeText(
                                        "Meal Rate",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              
                            },
                          ),
                        ),
              
                        SizedBox(
                          height: 150,
                          child: Card(
                            color: Colors.white70,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.no_meals_ouline),
                                  FittedBox( 
                                    child: Text(getFormatedPrice(value: firstScreenProvider.getMyTotalMeal), style: getTextStyleForTitleM()),
                                            
                                  ),
                                      AutoSizeText(
                                        "My Total Meal",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                       
                      
                     
                      
                        SizedBox(
                          height: 150,
                          child: Card(
                            color: Colors.white70,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FaIcon(FontAwesomeIcons.bangladeshiTakaSign ,size: 15,),
                                  FittedBox( 
                                    child: Text(getFormatedPrice(value: firstScreenProvider.getMyTotalDeposit), style: getTextStyleForTitleM()),
                                            
                                  ),
                                      AutoSizeText(
                                        "My Deposit",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: Card(
                            color: Colors.white70,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FaIcon(FontAwesomeIcons.bangladeshiTakaSign ,size: 15,),
                                  FittedBox( 
                                    child: Text(getFormatedPrice(value: firstScreenProvider.getMyRemainingTk), style: getTextStyleForTitleM()),
                                            
                                  ),
                                      AutoSizeText(
                                        "Remaining",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
              
              
                        SizedBox(
                          height: 150,
                          child: GestureDetector(
                            child: Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.set_meal_rounded),
                                    FittedBox( 
                                      child: Text(getFormatedPrice(value: firstScreenProvider.getTotalMealOfMess), style: getTextStyleForTitleM()),
                                        
                                    ),
                                      AutoSizeText(
                                        "Total Meal of Mess",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              
                            },
                          ),
                        ),
              
                        SizedBox(
                          height: 150,
                          child: Card(
                            color: Colors.white70,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FaIcon(FontAwesomeIcons.bangladeshiTakaSign ,size: 15,),
                                  FittedBox( 
                                    child: Text(getFormatedPrice(value: firstScreenProvider.getTotalBazerCost), style: getTextStyleForTitleM()),
                                            
                                  ),
                                  
                                      AutoSizeText(
                                        "Bazer Cost",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: Card(
                            color: Colors.white70,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FaIcon(FontAwesomeIcons.starHalfStroke ,size: 15,),
                                  FittedBox( 
                                    child: Text(getFormatedPrice(value: firstScreenProvider.getRemainingFundBlance), style: getTextStyleForTitleM()),
                                            
                                  ),
                                      AutoSizeText(
                                        "Fund Blance",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
              
                        
                      ],
                    ),
              
                    Card(
                      color: Colors.white70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Icon(Icons.push_pin_rounded),
                                      AutoSizeText(
                                        "Pind Notice",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 10,
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                firstScreenProvider.getPindedNoticeForHome==null? Center(child: Text("Nothing"))
                                :
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 20,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        style: getTextStyleForSubTitleXL(), 
                                        children: [
                                          TextSpan(
                                            text: "Notice Id: ",
                                            style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text:firstScreenProvider.getPindedNoticeForHome?.noticeId.toString(),
                                          ),
                                        ]
                                      )
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        style: getTextStyleForSubTitleXL(), 
                                        children: [
                                          TextSpan(
                                            text: "Title: ",
                                            style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text:(firstScreenProvider.getPindedNoticeForHome!.title).toString(),
                                          ),
                                        ]
                                      )
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        style: getTextStyleForSubTitleXL(), 
                                        children: [
                                          TextSpan(
                                            text: "Description: ",
                                            style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text:(firstScreenProvider.getPindedNoticeForHome?.description).toString(),
                                          ),
                                        ]
                                      )
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        style: getTextStyleForSubTitleXL(), 
                                        children: [
                                          TextSpan(
                                            text: "Time: ",
                                            style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text:(DateFormat("hh:mm a dd-MM-yyyy").format(firstScreenProvider.getPindedNoticeForHome!.CreatedAt!.toDate().toLocal())).toString(),
                                          ),
                                        ]
                                      )
                                    ),
                                   
                                  ],
                                )
                                
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),    
                  ],
                ),
              ),
            ),
        );
  }
}