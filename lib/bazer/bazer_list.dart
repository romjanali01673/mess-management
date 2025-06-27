import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/bazer/bazer_entry.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/bazer_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/bazer_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class BazerListScreen extends StatefulWidget {
  const BazerListScreen({super.key});

  @override
  State<BazerListScreen> createState() => _BazerListScreenState();
}

class _BazerListScreenState extends State<BazerListScreen> {
  bool showCost = false;
  List<bool> showDetails = [];
  
  @override
  Widget build(BuildContext context) {
  final bazerProvider = context.watch<BazerProvider>();
  final authProvider = context.watch<AuthenticationProvider>();
  final messProvider = context.watch<MessProvider>();
    return Expanded(
      child: Column(
        children: [
          Card(
            color: Colors.green.shade500,
            child: ListTile(
              trailing: IconButton(
                onPressed: (){
                  setState(() {
                  showCost = !showCost;
                    
                  });
                }, 
                icon: showCost?  Icon(Icons.visibility) : Icon(Icons.visibility_off),
              ),
              title: 
              showCost? Text("Total Cost: ${bazerProvider.getCost}",)
              :
              Text("tap to see Cost"),
            ),
          ),
      
          // amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider)?
          Expanded(
               child: FutureBuilder(
                future: bazerProvider.getBazerTransactions(
                  messId: authProvider.getUserModel!.currentMessId, 
                  mealHisabId: authProvider.getUserModel!.mealHisabId, 
                  onFail: (message){
                  }
                ),
                builder: (context,AsyncSnapshot<List<BazerModel>?> snapshot) {
                  showDetails.clear();
                  if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                    return Center(child: showCircularProgressIndicator());
                  }
                  else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } 
                  else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No Transaction found.'));
                  }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context , index){
                    BazerModel bazerModel = snapshot.data![index];
                    showDetails.add(false);
                  return StatefulBuilder(
                    builder: (context, setLocalState){

                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            
                            contentPadding: EdgeInsets.only(left: 2),
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Text("$index"),
                            ),
                            title: Text("${DateFormat("hh:mm a dd-MM-yyyy").format(bazerModel.CreatedAt!.toDate().toLocal())}",style : getTextStyleForTitleM()), // entry time 
                            subtitle: Text(bazerModel.byWho[Constants.fname]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(bazerModel.amount.toString(), style: TextStyle(fontSize: 18),),// amount
                                PopupMenuButton(
                                  icon: Icon(Icons.more_vert),
                                  itemBuilder: (context) =>[
                                    PopupMenuItem(
                                      value: 0,
                                      child: ListTile(
                                        title: Text("Edit",style : getTextStyleForTitleM()),
                                        leading: Icon(Icons.edit),
                                        onTap: ()async{
                                          Navigator.pop(context);
                                          
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> BazerEntryScreen(preBazerModel: bazerModel)));
                                        },
                                      ),
                                    ),
                                 
                                    PopupMenuItem(
                                      value: 1,
                                      // onTap: (){
                                      //   // if i use this function. we don't need to Navigator.pop()
                                      // },
                                      child: ListTile(
                                        title: Text("Delete",style : getTextStyleForTitleM()),
                                        leading: Icon(Icons.delete),
                                        onTap: ()async{
                                          Navigator.pop(context); // if i use this function. we have to Navigator.pop() for close listview and can't called parent/PopupMenuItem's ontap function
                                          bool? confirm = await showConfirmDialog(
                                            context: context, 
                                            title: "Do you want to delete?",
                                          );
                                          if(confirm!=null && confirm){
                                            debugPrint("Confirmed ------------");
                                            await bazerProvider.deleteABazerTransaction(
                                              tnxId: bazerModel.tnxId, 
                                              messId: authProvider.getUserModel!.currentMessId, 
                                              mealHisabId: authProvider.getUserModel!.mealHisabId, 
                                              extraAdd: (bazerModel.amount * -1), 
                                              onFail: (message){
                                                showSnackber(context: context, content: "Deletion Failed.\n$message");
                                              },
                                              onSuccess: () {
                                                showSnackber(context: context, content: "Deletion Success.");
                                              },
                                            );
                                          }
                                        },
                                      ), 
                                    ),
                                 
                                  ])
                              ],
                            ),
                            onTap: (){
                              // show details here 
                              setLocalState(() {
                                showDetails[index] = !showDetails[index];
                    
                                debugPrint("show details");
                              });
                            },
                          ),
                          
                          showDetails[index] ?
                          Column(
                           children: [
                              Text("His/Her Id: ${bazerModel.byWho[Constants.uId]}"),
                              Text("Bazer Time: ${bazerModel.bazerTime}"),
                              Text("Bazer Date: ${bazerModel.bazerDate}"),
                              Text("the details list of bazer below:"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("SL No"),
                                  Text("Product"),
                                  Text("Price"),
                                ],
                              ),
                              Divider(),
                              ...List.generate(bazerModel.bazerList!.length, (index){
                                return Container(
                                  color: index%2==0? Colors.amber.shade50:Colors.green.shade50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    spacing: 10,
                                    children: [
                                      Text("${index+1}."),
                                      Expanded(child: Text("${bazerModel.bazerList![index][Constants.product]}",textAlign: TextAlign.center,)),
                                      Text("${bazerModel.bazerList![index][Constants.price]}"),
                                    ],
                                  ),
                                );
                              }),
                           ], 
                          )
                          :
                          SizedBox.shrink(),
                        ],
                      ),
                    );
                    }
                  );
                },
                  );
                },
               ),
          )
          // :
          // Text("required menager/Act menager power"),
        ],
      ),
    );
  }
}