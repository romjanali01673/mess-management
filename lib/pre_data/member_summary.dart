

import 'dart:typed_data';

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
import 'package:mess_management/pdf_preview.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
  
class MemberSummary extends StatefulWidget{
  final MemberSummaryModel memberSummaryModel;
  const MemberSummary({super.key,required this.memberSummaryModel});

  @override
  State<MemberSummary> createState()=>_MemberSummaryState();
}

class _MemberSummaryState extends State<MemberSummary>{
  ScreenshotController ssController = ScreenshotController();

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
                child: Stack(
                  children: [
        
                    Screenshot(
                      controller: ssController,
                      child: getSummary(),
                    ),
        
                    Positioned(
                              top: 0,
                              right: 0,
                              child: ElevatedButton(
                                onPressed: () async{
                                    print("object0");
                                  Uint8List? _imageFile;
                                  await ssController.capture().then((Uint8List ?image) {
                                      setState(() {
                                          _imageFile = image;
                                      });
                                  }).catchError((onError) {
                                      print(onError);
                                  });
                                    print("object1");
        
                                // // for long unbuild ss
                                // check in screenshot package documentations,
                                
                                // // for long ss 
                                // await ssController
                                //       .captureFromLongWidget(
                                //           InheritedTheme.captureAll(
                                            
                                //             context, 
                                //             Material(
                                //               child: getSummary(),
                                //             ),
                                //           ),
                                //           delay: Duration(milliseconds: 100),
                                //           context: context,
                                //       )
                                //       .then((capturedImage) {
                                //     // Handle captured image
                                //     _imageFile = capturedImage;
                                //   });
        
        
                                  if(_imageFile!=null){
                                    print("object2");
                                    final pdf = pw.Document();
          
                                    pdf.addPage(
                                      pw.Page(
                                        margin: pw.EdgeInsets.all(0),
                                        build: (pw.Context context) => pw.Center(
                                          child: pw.Column(
                                            mainAxisSize: pw.MainAxisSize.min,
                                            children: [
                                              pw.Container(
                                                height: 800, // or adjust as needed
                                                child: pw.Image(
                                                  fit: pw.BoxFit.scaleDown,
                                                  pw.MemoryImage(_imageFile!)
                                                ),
                                              ),
                                              pw.Align(
                                                alignment: pw.Alignment.bottomCenter,
                                                child: pw.Text("It's a system genarated document so dose not required any signature or ETC.")
                                              ),
                                            ]
                                          ) 
                                        ),
                                      ),
                                    );

                                    // for open, save, preview, print.
                                    // await Printing.layoutPdf(
                                    // onLayout: (PdfPageFormat format) async => pdf.save());
                                    
                                    // for show preview in flutter page
                                    final PdfFile = await pdf.save();
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PdfPreviewScreen(PdfFile: PdfFile)));
                                  }
                                }, 
                                style: getTextbuttonStyle().copyWith(
                                  foregroundColor: WidgetStateProperty.all(
                                    Colors.red
                                  )
                                ),
                                child: Text("Print"),
                              ),
                            )
        
                  ],
                ),
              ),
            ];
          },
          
          body:Column(
            children: [
              selectedOption==""? Center(
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
            ],
          )
        )
        
        
        
        
      ),
    );
  }



  Widget getSummary(){
    return Card(
        color: Colors.green.shade50,
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
                  Row(
                    children: [],
                  ),
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
                style: getTextbuttonStyle().copyWith(),
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
                style: getTextbuttonStyle().copyWith(),
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
                style: getTextbuttonStyle().copyWith(),
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
                
                style: getTextbuttonStyle().copyWith(),
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
    );
  }


}