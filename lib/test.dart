import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/fund/fand_list.dart';
import 'package:mess_management/fund/fund_entry.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/testProvider.dart';
import 'package:provider/provider.dart';



class TestFundList extends StatefulWidget {
  final Timestamp? fromDate;
  final Timestamp? toDate;
  final bool fromPreMember;
  final String? messId;
  const TestFundList({
    super.key,
    this.fromPreMember = false,
    this.fromDate,
    this.toDate,
    this.messId,
  });

  @override
  State<TestFundList> createState() => _TestFundListState();
}



class _TestFundListState extends State<TestFundList> {
  bool showBlance = false;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> itemKeys = [];
  final GlobalKey listviewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final fundProvider = context.read<Testprovider>();
      final authProvider = context.read<AuthenticationProvider>();

      if (widget.fromPreMember) {
        fundProvider.loadForASpacificRange(
          messId: widget.messId!,
          fromDate: widget.fromDate!,
          toDate: widget.toDate!,
        );
      } else {
        fundProvider.listenFundBlance(
          messId: authProvider.getUserModel!.currentMessId,
        );
        fundProvider.listenFundDocChanges(
          messId: authProvider.getUserModel!.currentMessId,
        );
        fundProvider.loadInitial(
          messId: authProvider.getUserModel!.currentMessId,
        );
      }

      _scrollController.addListener(_handleScroll);
    });
  }





  void _handleScroll() {
    // In async operations, the widget might dispose while data is loading. safty check
    if (!_scrollController.hasClients) return;

    final fundProvider = context.read<Testprovider>();
    final authProvider = context.read<AuthenticationProvider>();

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final scrollDirection = _scrollController.position.userScrollDirection;

    // print(currentScroll);



    // if (_scrollController.hasClients && fundProvider.currentDocs.length > 100  && scrollDirection == ScrollDirection.reverse && currentScroll >= maxScroll-25000) {
    //             double totalHeight = 0; 
    //             for(int i =0; i< itemKeys.length; i++){
    //               final contexta = itemKeys[i].currentContext;
    //               if (contexta != null) {
    //                 final box = contexta.findRenderObject() as RenderBox;
    //                 final height = box.size.height;
    //                 totalHeight += height;

    //                 // print("height $i: $height");
    //               }
    //             }
    //             print("current Height: $currentScroll"+" 1");
    //             print("current Height: $currentScroll"+" 2");

    //             setState(() {
    //             _scrollController.jumpTo(currentScroll-(100*20));
    //             fundProvider.currentDocs.removeRange(0,50);
                  
    //             });
    //             // itemKeys.removeRange(0,50);
    //             print("item keys length: ${itemKeys.length}");
    //             print("total Height: $totalHeight");
    //             print("MaX height: ${maxScroll}");


    // //         final context = listviewKey.currentContext;
    // // if (context != null) {
    // //   final RenderBox box = context.findRenderObject() as RenderBox;
    // //   final double totalHeight = box.size.height;

    // //   print("Total rendered ListView height: $totalHeight");
    // // } else {
    // //   print("ListView context is null (not built yet)");
    // // }

    // }

    if (currentScroll >= maxScroll-1000 && scrollDirection == ScrollDirection.reverse) {
        fundProvider
          .loadNext(messId: authProvider.getUserModel!.currentMessId)
          .then((_) {
            // Small delay to allow list to rebuild
            Future.delayed(const Duration(milliseconds: 1000), () {
              
            });
      });
    }
    if (currentScroll  <= 300 && scrollDirection == ScrollDirection.forward) {
        fundProvider
          .loadPrevious(messId: authProvider.getUserModel!.currentMessId)
          .then((_) {
            // Small delay to allow list to rebuild
            Future.delayed(const Duration(milliseconds: 1000), () {
              
            });
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

  bool isDarkMode = false;
  
  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authProvider =
    context.read<AuthenticationProvider>();
    Testprovider fundProvider = context.read<Testprovider>();
    return Scaffold(
      body: Container(
        color: Colors.green.shade100,
        child: Consumer<Testprovider>(
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return Card(
                color: Colors.green.shade500,
                child: ListTile(
                  trailing: IconButton(
                    onPressed: () {
                      setLocalState(() {
                        showBlance = !showBlance;
                      });
                    },
                    icon:
                        showBlance
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                  ),
                  title:
                      showBlance
                          ? Text(
                            "Current Blance: ${getFormatedPrice(value: fundProvider.getBlance)}",
                          )
                          : Text("tap to see blance"),
                ),
              );
            },
          ),


          builder:
              (context, value, child) { 
                debugPrint("working with ${fundProvider.currentDocs.length}");
                return Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),

                  SwitchListTile(
                    title: Text("Tnx Type"),
                    subtitle: isDarkMode? Text("Add") : Text("Refund"),
                    value: isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                    secondary: Icon(Icons.playlist_add_check_circle), //Icon(Icons.dark_mode),
                    activeColor: Colors.black,
                    activeTrackColor: Colors.blue,
                  ),
                  
                  // ElevatedButton.icon(
                  //   onPressed: ()async{
                  //     await fundProvider.set100record(authProvider.getUserModel!.currentMessId);
                  //   }, 
                  //   label: Text("add 1000")
                  // ),
                  SizedBox(height: Platform.isIOS ? 40 : 10),
                  if (!widget.fromPreMember)
                    child!, // the child will not rebuild
                  if (fundProvider.getFundModelList.isEmpty)
                    Center(child: Text('No Transaction found.')
                  ),
                  Expanded(
                    child:ListView.builder(
                      controller: _scrollController,
                      itemCount:  fundProvider.currentDocs.length,
                      itemBuilder: (context, index) {
                          
                            if (itemKeys.length <= index) {
                              itemKeys.add(GlobalKey());
                  
                            }
                                   
                            bool showDetails = false;
                            final fundmodel =
                                fundProvider.getFundModelList[index];
                                      
                            return StatefulBuilder(
                              builder: (context, setLocalState) {
                                return Container(
                                  key: itemKeys[index],
                                  color:
                                      fundmodel.type == Constants.add
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ListTile(
                                        onTap: () {
                                          setLocalState(() {
                                            showDetails = !showDetails;
                                          });
                                        },
                                        contentPadding: EdgeInsets.only(left: 10),
                                        leading: Text("${index + 1}"),
                                        title: Text(fundmodel.title), // title
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("${fundmodel.type}"), // type
                                            Text(
                                              "${DateFormat("hh:mm a dd-MM-yyyy").format(fundmodel.CreatedAt!.toDate().toLocal())}",
                                            ),
                                            // Text((fundmodel.CreatedAt!.toDate().toString())),
                                          ],
                                        ),
                                        
                                      ),
                                      if (showDetails)
                                        Text("${fundmodel.description??"k"}"),
                                    ],
                                  ),
                                );
                              },
                            );
                        }, 
                      ),
                  ),
                  if (fundProvider.isLoading) showCircularProgressIndicator(),
                  // else
                  //   Expanded(
                  //     child: ListView.builder(
                  //       key: listviewKey,
                  //       controller: _scrollController,
                  //       shrinkWrap: true,
                  //       // physics: NeverScrollableScrollPhysics(),
                  //       itemCount: fundProvider.getFundModelList.length ,//+ 1,
                  //       itemBuilder: (context, index) {
                  //       },
                  //     ),
                  //   ),
                ],
                              );
            }
        ),
      ),
    );
  }
}
