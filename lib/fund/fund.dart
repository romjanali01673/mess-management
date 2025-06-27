import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/fund/clear_fund.dart';
import 'package:meal_hisab/fund/fund_entry.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/fund_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/fund_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:meal_hisab/ui_helper/ui_helper.dart';
import 'package:provider/provider.dart';

class FundScreen extends StatefulWidget {
  const FundScreen({super.key});

  @override
  State<FundScreen> createState() => _FundScreenState();
}

class _FundScreenState extends State<FundScreen> {
  Fund fundItemGroup = Fund.fund;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  spacing: 10,
                  children: [
                    getMenuItems(
                      label: "Fund", 
                      icon: FontAwesomeIcons.bangladeshiTakaSign,
                      ontap: (){
                        fundItemGroup = Fund.fund;
                        setState(() {
                          
                        });
                            
                      },
                      selected: fundItemGroup == Fund.fund,
                    ),
                    getMenuItems(
                      icon: Icons.create,
                      label: "Entry", 
                      ontap: (){
                        // fundItemGroup = Fund.addDeposit;
                        // setState(() {
                          
                        // });
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AddFund()));
                      },
                      selected: fundItemGroup == Fund.addDeposit,
                    ),
                    getMenuItems(
                      icon: Icons.clear,
                      label: "Clear", 
                      ontap: ()async{
                        fundItemGroup = Fund.clearFund;
                        setState(() {
                          
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ClearFund()));
                      },
                      selected: fundItemGroup == Fund.clearFund,
                    ),
                   
                  ],
                ),
              ),
            ),
            FundHome(),
          ],     
        ),
      ),
    );
  }
}


class FundHome extends StatefulWidget {
  const FundHome({super.key});

  @override
  State<FundHome> createState() => _FundHomeState();
}

class _FundHomeState extends State<FundHome> {

  bool showBlance = false;
    ScrollController  _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    
    final fundProvider = context.read<FundProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    
    fundProvider.listenFundBlance(messId: authProvider.getUserModel!.currentMessId);
    fundProvider.listenFundDocChanges(messId: authProvider.getUserModel!.currentMessId);
    fundProvider.loadInitial(messId: authProvider.getUserModel!.currentMessId);

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

    return Expanded(

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
          
        builder: (context, value, child) => Column(
        children: [
          child!,     // the child will not rebuild        
          if (fundProvider.getFundModelList.isEmpty)  Center(child: Text('No Transaction found.'))
          else Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
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
                                trailing: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}