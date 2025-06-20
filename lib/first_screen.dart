import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/notice_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/firstScreen_provider.dart';
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
    firstScreenProvider.getFandBlance(messId: authProvider.getUserModel!.currentMessId, onFail: (_){});
    firstScreenProvider.getTotalMeal(messId: authProvider.getUserModel!.currentMessId, onFail: (_){});
    firstScreenProvider.getTotalBazer(messId: authProvider.getUserModel!.currentMessId, onFail: (_){});
    firstScreenProvider.getTotalDeposit(messId: authProvider.getUserModel!.currentMessId, onFail: (_){});
    firstScreenProvider.getTotalDepositOfMember(uId: authProvider.getUserModel!.uId, messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, );
    firstScreenProvider.getTotalMealOfMember(uId: authProvider.getUserModel!.uId, messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, );
    firstScreenProvider.getPindNoticeForHomeFromDatabase( messId: authProvider.getUserModel!.currentMessId, onFail: (_){}, );
  }

  @override
  Widget build(BuildContext context) {
    final firstScreenProvider = context.watch<FirstScreenProvider>();

    return Container(  // home Screen
        height: double.infinity,
        width: double.infinity,
        color: Colors.green.shade100,
        child: FutureBuilder(
          future: Future.delayed(Duration(seconds: 1)),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
              return Center(child: showCircularProgressIndicator());
            }
            else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } 
            else if (!snapshot.hasData || snapshot.data == null) {
              // return Center(child: Text('Somthing Wrong'));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  FadeInUp(duration: Duration(milliseconds:100),
                    child: Text("Welcome Back", style:TextStyle(fontSize: 30, color: Colors.red.shade800),),
                  ),
                  GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: .9,
                    children: [
                      SizedBox(
                        height: 150,
                        child: GestureDetector(
                          child: Card(
                            color: Colors.white70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.bangladeshiTakaSign),
                                FittedBox( 
                                  child: Text(getFormatedPrice(value: firstScreenProvider.getMealRate), style: TextStyle(fontSize: 40)),
                                    
                                ),
                                Text("Meal Rate",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                              ],
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.no_meals_ouline),
                              FittedBox( 
                                child: Text(getFormatedPrice(value: firstScreenProvider.getMyTotalMeal), style: TextStyle(fontSize: 40)),
              
                              ),
                              Text("My Total Meal ",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                    
                     
                    
                   
                    
                      SizedBox(
                        height: 150,
                        child: Card(
                          color: Colors.white70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.bangladeshiTakaSign),
                              FittedBox( 
                                child: Text(getFormatedPrice(value: firstScreenProvider.getMyTotalDeposit), style: TextStyle(fontSize: 40)),
              
                              ),
                              Text("Total Deposit TK",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: Card(
                          color: Colors.white70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.bangladeshiTakaSign),
                              FittedBox( 
                                child: Text(getFormatedPrice(value: firstScreenProvider.getMyRemainingTk), style: TextStyle(fontSize: 40)),
              
                              ),
                              Text("Remaining Tk",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
            
            
                      SizedBox(
                        height: 150,
                        child: GestureDetector(
                          child: Card(
                            color: Colors.white70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.set_meal_rounded),
                                FittedBox( 
                                  child: Text(getFormatedPrice(value: firstScreenProvider.getTotalMealOfMess), style: TextStyle(fontSize: 40)),
                                    
                                ),
                                Text("Total Meal Of Mess",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                              ],
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.bangladeshiTakaSign),
                              FittedBox( 
                                child: Text(getFormatedPrice(value: firstScreenProvider.getTotalBazerCost), style: TextStyle(fontSize: 40)),
              
                              ),
                              
                              Text("Total Bazer Cost",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: Card(
                          color: Colors.white70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.starHalfStroke),
                              FittedBox( 
                                child: Text(getFormatedPrice(value: firstScreenProvider.getRemainingFandBlance), style: TextStyle(fontSize: 40)),
              
                              ),
                              Text("Fand Blance",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: Card(
                          color: Colors.white70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.starHalfStroke),
                              FittedBox( 
                                child: Text(getFormatedPrice(value: firstScreenProvider.getTotalDepositOfMess), style: TextStyle(fontSize: 40)),
              
                              ),
                              Text("Total Deposit Of Mess",style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                            ],
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
                              Text("Pind Notice"),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              firstScreenProvider.getPindedNoticeForHome==null? Text("Nothing")
                              :
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 20,
                                children: [
                                  Text("Notice Id:${firstScreenProvider.getPindedNoticeForHome!.noticeId}",),
                                  Text("Title: ${firstScreenProvider.getPindedNoticeForHome!.title}"),
                                  Text("Description ${firstScreenProvider.getPindedNoticeForHome!.description}",),
                                  Text("Time: ${DateFormat("hh:mm a dd-MM-yyyy").format(firstScreenProvider.getPindedNoticeForHome!.CreatedAt!.toDate().toLocal())}",),
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
            );
          }
        ),
      );
  }
}