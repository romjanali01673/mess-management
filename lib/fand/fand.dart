import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/fand/fand_entry.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/fand_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/fand_provider.dart';
import 'package:meal_hisab/ui_helper/ui_helper.dart';
import 'package:provider/provider.dart';

class FandScreen extends StatefulWidget {
  const FandScreen({super.key});

  @override
  State<FandScreen> createState() => _FandScreenState();
}

class _FandScreenState extends State<FandScreen> {
  Fand fandItemGroup = Fand.fand;

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
                      label: "Fand", 
                      icon: FontAwesomeIcons.bangladeshiTakaSign,
                      ontap: (){
                        fandItemGroup = Fand.fand;
                        setState(() {
                          
                        });
                            
                      },
                      selected: fandItemGroup == Fand.fand,
                    ),
                    getMenuItems(
                      icon: Icons.create,
                      label: "Entry", 
                      ontap: (){
                        // fandItemGroup = Fand.addDeposit;
                        // setState(() {
                          
                        // });
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AddFand()));
                      },
                      selected: fandItemGroup == Fand.addDeposit,
                    ),
                   
                  ],
                ),
              ),
            ),
            FandHome(),
          ],     
        ),
      ),
    );
  }
}


class FandHome extends StatefulWidget {
  const FandHome({super.key});

  @override
  State<FandHome> createState() => _FandHomeState();
}

class _FandHomeState extends State<FandHome> {

  bool showBlance = false;
    ScrollController  _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    
    final fandProvider = context.read<FandProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    
    fandProvider.listenFand(messId: authProvider.getUserModel!.currentMessId);
    fandProvider.listenFandDocChanges(messId: authProvider.getUserModel!.currentMessId);
    fandProvider.loadInitial(messId: authProvider.getUserModel!.currentMessId);

    // _scrollController.addListener(_handleScroll);
  });
}

void _handleScroll() {
  // In async operations, the widget might dispose while data is loading. safty check
  if (!_scrollController.hasClients) return;
  
  final fandProvider = context.read<FandProvider>();
  final authProvider = context.read<AuthenticationProvider>();

  final maxScroll = _scrollController.position.maxScrollExtent;
  final currentScroll = _scrollController.position.pixels;
  final scrollDirection = _scrollController.position.userScrollDirection;

  // Load more when scrolled to bottom
  if (currentScroll >= maxScroll && 
      scrollDirection == ScrollDirection.reverse) {
    if (!fandProvider.getHasMoreForword || fandProvider.isLoading) return;
    
    fandProvider.loadNext(messId: authProvider.getUserModel!.currentMessId)
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
    if (!fandProvider.getHasMoreBackword || fandProvider.isLoading) return;
    
    final previousLength = fandProvider.getFandModelList.length;
    
    fandProvider.loadPrevious(messId: authProvider.getUserModel!.currentMessId)
      .then((_) {
        if (_scrollController.hasClients) {
          // Adjust scroll position to maintain view
          final newLength = fandProvider.getFandModelList.length;
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
        debugPrint(context.read<FandProvider>().currentDocs.length.toString()+"h");

    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();
    FandProvider fandProvider = context.read<FandProvider>();

    return Expanded(

      child: Consumer<FandProvider>(
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
                      showBlance? Text("Current Blance: ${getFormatedPrice(value: fandProvider.getBlance)}",)
                      :
                      Text("tap to see blance"),
                    ),
                  );
          
            }),
          
        builder: (context, value, child) => Column(
        children: [
          child!,     // the child will not rebuild        
          if (fandProvider.getFandModelList.isEmpty)  Center(child: Text('No Transaction found.'))
          else Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount:fandProvider.getFandModelList.length+1,
              itemBuilder: (context , index){
                if(index==fandProvider.getFandModelList.length){
                 return Center(
                   child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                     child: fandProvider.isLoading? showCircularProgressIndicator() :Row(
                      mainAxisAlignment:(fandProvider.getHasMoreBackword && fandProvider.getHasMoreForword)? MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
                      children: [
                         if(fandProvider.getHasMoreBackword) ElevatedButton(
                           onPressed: (){fandProvider.loadPrevious(messId: authProvider.getUserModel!.currentMessId).then((_){
                             if(_scrollController.hasClients){
                               // _scrollController.jumpTo(
                               //   _scrollController.position.minScrollExtent,
                               // );
                             }
                             });},
                             child: Text("Prev")
                           ),
                     
                        if(fandProvider.getHasMoreForword) ElevatedButton(
                          onPressed: (){fandProvider.loadNext(messId: authProvider.getUserModel!.currentMessId).then((_){
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
                final fandmodel = fandProvider.getFandModelList[index]; 


                return StatefulBuilder(
                        builder: (context, setLocalState) {
                          return Card(
                            color: fandmodel.type==Constants.add? Colors.green.shade50:Colors.red.shade50,
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
                                title: Text(fandmodel.title),// title
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${fandmodel.type}"), // type
                                    Text("${DateFormat("hh:mm a dd-MM-yyyy").format(fandmodel.CreatedAt!.toDate().toLocal())}"),
                                    // Text((fandmodel.CreatedAt!.toDate().toString())),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    showPrice(value: fandmodel.amount),
                                    PopupMenuButton(
                                      icon: Icon(Icons.more_vert),
                                      itemBuilder: (context) =>[
                                        
                                        PopupMenuItem(
                                          value: 0,
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddFand(preFandModel: fandmodel,)));
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
                                              fandProvider.deleteAFandTransaction(
                                                messId: authProvider.getUserModel!.currentMessId, 
                                                tnxId: fandmodel.tnxId, 
                                                extraAmount: fandmodel.type==Constants.add? (-fandmodel.amount) : fandmodel.amount, 
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
                            if(showDetails)Text("${fandmodel.description}"),
                            
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