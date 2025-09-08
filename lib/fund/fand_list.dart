


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/fund/fund_entry.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/fund_provider.dart';
import 'package:provider/provider.dart';

class FundList extends StatefulWidget {
  final Timestamp? fromDate;
  final Timestamp? toDate;
  final bool fromPreMember;
  final String? messId;
  const FundList({super.key, this.fromPreMember = false, this.fromDate, this.toDate, this.messId });

  @override
  State<FundList> createState() => _FundListState();
}

class _FundListState extends State<FundList> {

  bool showBlance = false;
    ScrollController  _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    
    final fundProvider = context.read<FundProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    
    if(widget.fromPreMember){
      
      fundProvider.loadForASpacificRange(messId: widget.messId!, fromDate: widget.fromDate!, toDate: widget.toDate!);
    }
    else{
      fundProvider.listenFundBlance(messId: authProvider.getUserModel!.currentMessId);
      fundProvider.listenFundDocChanges(messId: authProvider.getUserModel!.currentMessId);
      fundProvider.loadInitial(messId: authProvider.getUserModel!.currentMessId);
    }

    // _scrollController.addListener(_handleScroll);
  });
}

void _handleScroll() {
  // In async operations, the widget might dispose while data is loading. safty check
  if (!_scrollController.hasClients) return;
  
  final fundProvider = context.read<FundProvider>();
  final authProvider = context.read<AuthenticationProvider>();

  final maxScroll = _scrollController.position.maxScrollExtent;
  final currentScroll = _scrollController.position.pixels;
  final scrollDirection = _scrollController.position.userScrollDirection;

  // Load more when scrolled to bottom
  if (currentScroll >= maxScroll && 
      scrollDirection == ScrollDirection.reverse) {
    if (!fundProvider.getHasMoreForword || fundProvider.isLoading) return;
    
    fundProvider.loadNext(messId: authProvider.getUserModel!.currentMessId)
      .then((_) {
        // Small delay to allow list to rebuild
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            // Maintain position near bottom
            // _scrollController.jumpTo(
            //   _scrollController.position.maxScrollExtent - 50
            // );
          }
        });
      });
  }

  // Load previous when scrolled to top
  if (currentScroll <= _scrollController.position.minScrollExtent && 
      scrollDirection == ScrollDirection.forward) {
    if (!fundProvider.getHasMoreBackword || fundProvider.isLoading) return;
    
    final previousLength = fundProvider.getFundModelList.length;
    
    fundProvider.loadPrevious(messId: authProvider.getUserModel!.currentMessId)
      .then((_) {
        if (_scrollController.hasClients) {
          // Adjust scroll position to maintain view
          final newLength = fundProvider.getFundModelList.length;
          final positionChange = (newLength - previousLength) * 100.0;
          // _scrollController.jumpTo(positionChange);
        }
      });
  }
}

  @override
  void dispose() {
  _scrollController.removeListener(_handleScroll);
  _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();
    FundProvider fundProvider = context.read<FundProvider>();

    return Scaffold(
      body: Container(
        color: Colors.green.shade100,
        child: Consumer<FundProvider>(
          child: StatefulBuilder(
            builder: (context, setLocalState) {
                  return Card(
                    color: Colors.green.shade500,
                    child: ListTile(
                      trailing: IconButton(
                        onPressed: (){
                          setLocalState(() {
                          showBlance = !showBlance;
                                
                            });
                          }, 
                          icon: showBlance?  Icon(Icons.visibility) : Icon(Icons.visibility_off),
                        ),
                        title: 
                        showBlance? Text("Current Blance: ${getFormatedPrice(value: fundProvider.getBlance)}",)
                        :
                        Text("tap to see blance"),
                      ),
                    );
            
              }),
            
          builder: (context, value, child) => SingleChildScrollView(
            // controller:widget.fromPreMember? null : _scrollController,
            child: Column(
            children: [
              SizedBox(
                height:Platform.isIOS? 40:10,
              ),
              if(!widget.fromPreMember) child!,     // the child will not rebuild    
              if(fundProvider.isLoading) showCircularProgressIndicator(),    
              if (fundProvider.getFundModelList.isEmpty)  Center(child: Text('No Transaction found.'))
              else 
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:fundProvider.getFundModelList.length+1,
                itemBuilder: (context , index){
                  if(index==fundProvider.getFundModelList.length){
                   return Center(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                       child: fundProvider.isLoading? showCircularProgressIndicator() :Row(
                        mainAxisAlignment:(fundProvider.getHasMoreBackword && fundProvider.getHasMoreForword)? MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
                        children: [
                           if(fundProvider.getHasMoreBackword) ElevatedButton(
                             onPressed: (){fundProvider.loadPrevious(messId: authProvider.getUserModel!.currentMessId).then((_){
                               if(_scrollController.hasClients){
                                 // _scrollController.jumpTo(
                                 //   _scrollController.position.minScrollExtent,
                                 // );
                               }
                               });},
                               child: Text("Prev")
                             ),
                       
                          if(fundProvider.getHasMoreForword) ElevatedButton(
                            onPressed: (){fundProvider.loadNext(messId: authProvider.getUserModel!.currentMessId).then((_){
                              if(_scrollController.hasClients){
                                _scrollController.jumpTo(
                                  _scrollController.position.minScrollExtent,
                                );
                              }
                              });},
                              child: Text(  "Next" )
                            ),
                          ]
                        ),
                     ),
                   );
                  }
                    
                  bool showDetails = false;
                  final fundmodel = fundProvider.getFundModelList[index]; 
                    
                    
                  return StatefulBuilder(
                          builder: (context, setLocalState) {
                            return Card(
                              color: fundmodel.type==Constants.add? Colors.green.shade50:Colors.red.shade50,
                              child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    setLocalState((){
                                      showDetails = !showDetails;
                                    });
                                  },
                                  contentPadding: EdgeInsets.only(left: 10),
                                  leading: Text("${index+1}",),
                                  title: Text(fundmodel.title),// title
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${fundmodel.type}"), // type
                                      Text("${DateFormat("hh:mm a dd-MM-yyyy").format(fundmodel.CreatedAt!.toDate().toLocal())}"),
                                      // Text((fundmodel.CreatedAt!.toDate().toString())),
                                    ],
                                  ), 
                                  trailing:widget.fromPreMember? SizedBox.shrink() : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      showPrice(value: fundmodel.amount),
                                      PopupMenuButton(
                                        icon: Icon(Icons.more_vert),
                                        itemBuilder: (context) =>[
                                          
                                          PopupMenuItem(
                                            value: 0,
                                            child: ListTile(
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddFund(preFundModel: fundmodel,)));
                                              },
                                              title: Text("Edit"),
                                              leading: Icon(Icons.edit, color: Colors.green,),
                                              ), 
                                          ),
                                
                                        PopupMenuItem(
                                          value: 1,
                                          // onTap: (){
                                          //   // if i use this function. we don't need to Navigator.pop()
                                          // },
                                          child: ListTile(
                                            title: Text("Delete"),
                                            leading: Icon(Icons.delete, color: Colors.red,),
                                            onTap: ()async{
                                              Navigator.pop(context); // if i use this function. we have to Navigator.pop() for close listview and can't called parent/PopupMenuItem's ontap function
                                              bool? confirm = await showDialog(context: context, builder: (content)=>AlertDialog(
                                                title: Text("Do you want to delete?"),
                                                actionsAlignment: MainAxisAlignment.start,
                                                actions: [
                                                  TextButton(child: Text("No"), onPressed: (){
                                                    Navigator.pop(context, false);
                                                  },),
                                                  TextButton(child: Text("Yes") , onPressed: (){
                                                  Navigator.pop(context, true);
                                                  },),
                                                ],
                                              ));
                                              if(confirm!=null && confirm){
                                                fundProvider.deleteAFundTransaction(
                                                  messId: authProvider.getUserModel!.currentMessId, 
                                                  tnxId: fundmodel.tnxId, 
                                                  extraAmount: fundmodel.type==Constants.add? (-fundmodel.amount) : fundmodel.amount, 
                                                  onSuccess: () {
                                                    showSnackber(context: context, content: "Deletion Successed.");
                                                    setState(() {
                                                      
                                                    });
                                                  },
                                                  onFail: (message){
                                                    showSnackber(context: context, content: "Deletion Failed!\n$message");
                                                  },
                                                );
                                              }
                                              else{
                                                  debugPrint("Confirmed false ------------");
                                              }
                                            },
                                          ), 
                                        ),
                                      ]
                                    )
                                  ],
                                ),
                              ),
                              if(showDetails)Text("${fundmodel.description}"),
                              
                            ],
                          ),
                        );
                      }
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}