import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/bazer/bazer_entry.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/bazer_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/bazer_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class BazerListScreen extends StatefulWidget {
  final Timestamp? fromDate;
  final Timestamp? toDate;
  final bool fromPreMember;
  final String? messId;
  final String? mealSessionId;
  const BazerListScreen({super.key, this.fromPreMember = false, this.fromDate, this.toDate, this.messId, this.mealSessionId });


  @override
  State<BazerListScreen> createState() => _BazerListScreenState();
}

class _BazerListScreenState extends State<BazerListScreen> {
  bool showCost = false;
  ScrollController  _scrollController = ScrollController();

  
  void setData()async{
    final bazerProvider =  context.read<BazerProvider>();
    final authProvider =  context.read<AuthenticationProvider>();

    if(widget.fromPreMember){
      await bazerProvider.loadInitial(
        messId: widget.messId!, 
        mealSessionId: widget.mealSessionId!,
      );
    }
    else{
      bazerProvider.listenBazerDocChanges(messId: authProvider.getUserModel!.currentMessId, mealSessionId: authProvider.getUserModel!.mealSessionId);
      await bazerProvider.loadInitial(
        messId: authProvider.getUserModel!.currentMessId, 
        mealSessionId: authProvider.getUserModel!.mealSessionId, 
      );
    }  
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      setData();
    });
  }
  

  @override
  Widget build(BuildContext context,) {

  final bazerProvider = context.watch<BazerProvider>();
  final authProvider = context.read<AuthenticationProvider>();
  final messProvider = context.read<MessProvider>();

  print(bazerProvider.currentDocs.length.toString() + "total docs");
    return 
    Expanded(
      child: Column(
        children: [
          if(!widget.fromPreMember)StatefulBuilder(
            builder: (context, setLocalState) {
              return Card(
                color: Colors.green.shade500,
                child: ListTile(
                  trailing: IconButton(
                    onPressed: (){
                      setLocalState(() {
                      showCost = !showCost;
                        
                      });
                    }, 
                    icon: showCost?  Icon(Icons.visibility) : Icon(Icons.visibility_off),
                  ),
                  title: 
                  showCost? Builder(
                    builder: (context) {
                      // return Text("Total Cost: ${bazerProvider.getCost}",);
                      return  FutureBuilder(
                        future: bazerProvider.getTotalBazerCost(
                          messId: authProvider.getUserModel!.currentMessId, 
                          mealSessionId: authProvider.getUserModel!.mealSessionId, 
                          onFail: (message){
                          }
                        ),
                        builder: (context,AsyncSnapshot<double> snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                            return Center(child: showCircularProgressIndicator());
                          }
                          else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } 
                          else if (!snapshot.hasData || snapshot.data == null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Text('No Transaction found.'),
                            );
                          }
                          return Text("Total Cost: ${getFormatedPrice(value: snapshot.data)}",);
                        }
                      );
      
                    }
                  )
                  :
                  Text("tap to see Cost"),
                ),
              );
            }
          ),
      
          // amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider)?
          Expanded(
            child: RefreshIndicator(
              onRefresh: ()async {
                if(widget.fromPreMember){
                  await bazerProvider.loadInitial(
                    messId: widget.messId!, 
                    mealSessionId: widget.mealSessionId!,
                  );
                }
                else{
                  await bazerProvider.loadInitial(
                    messId: authProvider.getUserModel!.currentMessId, 
                    mealSessionId: authProvider.getUserModel!.mealSessionId, 
                  );
                }
              },
              child: SingleChildScrollView(
                // widget.fromPreMember? NeverScrollableScrollPhysics() :
                physics:  ClampingScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  children: [
                    if(bazerProvider.currentDocs.isEmpty) Padding(
                      padding: EdgeInsets.only(top: 300),
                      child: Text("No Transactions Found")
                    ),
                
                    ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: bazerProvider.currentDocs.length,
                            itemBuilder: (context , index){
                            BazerModel bazerModel = bazerProvider.currentDocs[index];
                            bool showDetails = false;
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
                                      title: Text(
                                        "${DateFormat("hh:mm a dd-MM-yyyy").format(bazerModel.CreatedAt!.toDate().toLocal())}",
                                        style : getTextStyleForTitleS(),
                                      ), // entry time 
                                      subtitle: Text(
                                        bazerModel.byWho[Constants.fname],
                                        style : getTextStyleForSubTitleM().copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      trailing:  Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(getFormatedPrice(value: bazerModel.amount.toString()), style: TextStyle(fontSize: 18),),// amount
                                          PopupMenuButton(
                                            enabled: (amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider)) &&  !bazerProvider.isLoading &&  !widget.fromPreMember,
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
                                                        mealSessionId: authProvider.getUserModel!.mealSessionId, 
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
                                          showDetails = !showDetails;
                              
                                          debugPrint("show details");
                                        });
                                      },
                                    ),
                                    
                                    showDetails ?
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
                            }
                    ),
                    bazerProvider.isLoading ? showCircularProgressIndicator() 
                    : 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                      child: Row(
                        mainAxisAlignment:(bazerProvider.getHasMoreBackword && bazerProvider.getHasMoreForword)? MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
                        children: [
                          if(bazerProvider.getHasMoreBackword) ElevatedButton(
                             onPressed: (){
                              bazerProvider.loadPrevious(
                                messId:widget.fromPreMember? widget.messId! : authProvider.getUserModel!.currentMessId,
                                mealSessionId: widget.fromPreMember? widget.mealSessionId! : authProvider.getUserModel!.mealSessionId,
                              ).then((_){
                               if(_scrollController.hasClients){
                                 // _scrollController.jumpTo(
                                 //   _scrollController.position.minScrollExtent,
                                 // );
                               }
                               });},
                               child: Text("Prev")
                             ),
                       
                          if(bazerProvider.getHasMoreForword) ElevatedButton(
                            onPressed: (){
                            bazerProvider.loadNext(
                              messId:widget.fromPreMember? widget.messId! : authProvider.getUserModel!.currentMessId,
                              mealSessionId: widget.fromPreMember? widget.mealSessionId! : authProvider.getUserModel!.mealSessionId,
                            ).then((_){
                              if(_scrollController.hasClients){
                                _scrollController.jumpTo(
                                   _scrollController.position.minScrollExtent,
                                );
                              }
                            });},
                            child: Text(  "Next" )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
      
          // :
          // Text("required menager/Act menager power"),
        ],
      ),
    );
  }
}