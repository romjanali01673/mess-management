
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/deposit_model.dart';
import 'package:mess_management/model/fund_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/deposit_provider.dart';
import 'package:mess_management/providers/fund_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class AddFund extends StatefulWidget {
  final FundModel? preFundModel;
  const AddFund({super.key, this.preFundModel, });

  @override
  State<AddFund> createState() => _AddFundState();
}

class _AddFundState extends State<AddFund> {
  bool isUpdate = false;
  final formKey = GlobalKey<FormState>();

  FocusNode focusDiscreption = FocusNode();
  FocusNode focusAmount = FocusNode();
  FocusNode focusTitle = FocusNode();

  TextEditingController titleController = TextEditingController(); 
  TextEditingController descriptionController = TextEditingController(); 
  TextEditingController amountController = TextEditingController();
  bool isAdd = true;



  void setPreData(){
    isUpdate = true;
    titleController.text = widget.preFundModel!.title;
    descriptionController.text = widget.preFundModel!.description;
    amountController.text = widget.preFundModel!.amount.toString();
    isAdd = widget.preFundModel?.type == Constants.add;
  }

  @override
  void initState() {
    if(widget.preFundModel != null){
      setPreData();
    }
    
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    final fundProvider = context.watch<FundProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(// required scaffold 
        resizeToAvoidBottomInset: true,
        appBar: isUpdate? AppBar(
          title: Text("Edit Fund Tnx"),
          backgroundColor: Colors.grey,
        )
        : null,
        body: Container(
          height: double.infinity,
          color: Colors.green.shade50,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(
                  height:Platform.isIOS? 40:10,
                ),
                SwitchListTile(
                  
                  title: Text("Tnx Type"),
                  subtitle: isAdd? Text("Add") : Text("Cost"),
                  value: isAdd,
                  onChanged: (val){
                    if(!isUpdate){
                      setState(() {
                        isAdd = val;
                      });
                    }
                    else{
                      showSnackber(context: context, content: "For Update \"Entry Type\" Can't Be Changed");
                    }
                  },
                  secondary: Icon(Icons.playlist_add_check_circle), //Icon(Icons.dark_mode),
                  activeColor: Colors.black,
                  activeTrackColor: Colors.blue,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text("Cost"),
                //     Switch(
                      
                //       value: isAdd, 
                //       onChanged: (val){
                //         if(!isUpdate){
                //           setState(() {
                //             isAdd = val;
                //           });
                //         }
                //         else{
                //           showSnackber(context: context, content: "For Update \"Entry Type\" Can't Be Changed");
                //         }
                //       },
                //     ),
                //     Text("Add"),
                //   ],
                // ),
      
               
          
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: titleController,
                          // onTapOutside: (event) => FocusScope.of(context).unfocus(),
                          textInputAction: TextInputAction.next,
                          // autofocus: true,
                          focusNode: focusTitle,
                          onFieldSubmitted: (value){
                            FocusScope.of(context).requestFocus(focusDiscreption);
                          },
                          validator: (value) {
                            return titleValidator(value.toString());
                          },
      
                          decoration: FromFieldDecoration(
                            hintText: "Write here...",
                            label: "Title",
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: descriptionController,
                          // onTapOutside: (event) => FocusScope.of(context).unfocus(),
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          autofocus: false,
                          focusNode: focusDiscreption,
                          onFieldSubmitted: (value){
                            FocusScope.of(context).requestFocus(focusAmount);
                          },
                          // validator: (value) {
                          //   if(value.toString().trim()==""){
                          //     return "";
                          //   }
                          //   return null;
                          // },
      
                          decoration: FromFieldDecoration(
                            hintText: "Write About The Deposit",
                            label: "Discreption (Optional)",
                          )
                        ),
                      ),
                  
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: amountController,
                          // onTapOutside: (event) {
                            // FocusScope.of(context).unfocus();
                          // },
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          focusNode: focusAmount,
                          onFieldSubmitted: (value){
                            FocusScope.of(context).unfocus();
                          },
                          validator: (value) {
                            return validatePrice(value.toString());
                          },
                          decoration: FromFieldDecoration(
                            hintText: "How Much?",
                            label: "Amount",
                          )
                        ),
                      ),
                    ],
                  )
                ),   
      
                SizedBox(
                  height: 50,
                ),
      
                fundProvider.isLoading? showCircularProgressIndicator()
                : 
                getButton(
                  label: isUpdate?"Update":"Submit", 
                  ontap: ()async{
                  if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider)||amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                    showSnackber(context: context, content: "required Administrator power");
                    return;
                  }
      
                    bool valided  = (formKey.currentState!.validate());
                    
                    if(valided){
                      if(isUpdate){
                        await fundProvider.updateAFundTransaction(
                          fundModel : FundModel(
                            tnxId: widget.preFundModel!.tnxId, 
                            title: titleController.text.toString(), 
                            description: descriptionController.text.toString(), 
                            amount: double.parse(amountController.text.toString()), 
                            type: widget.preFundModel!.type, 
                          ), 
                          extraAmount: double.parse(amountController.text.toString()) - widget.preFundModel!.amount ,
                          messId: authProvider.getUserModel!.currentMessId, 
                          onFail: (message ) { 
                            showSnackber(context: context, content: "Updaate Failed! \n$message");
                          },
                          onSuccess: (){ 
                            formKey.currentState!.reset();
                            showSnackber(context: context, content: "Update Success!");
                            Navigator.of(context).pop();
                          }, 
                        );
                        // we should clear pre data other wise pre grabage data can make wrong submesion
                        isUpdate = false;
                        titleController.clear();
                        amountController.clear();
                        descriptionController.clear();
      
                        setState(() {
                              
                        });
                      }
                      else{
                        await fundProvider.addAFundTransaction(
                          fundModel : FundModel(
                            tnxId: DateTime.now().millisecondsSinceEpoch.toString(), 
                            title: titleController.text.toString(), 
                            description: descriptionController.text.toString(), 
                            amount: double.parse(amountController.text.toString()), 
                            type: isAdd? Constants.add : Constants.sub, 
                          ), 
                          messId: authProvider.getUserModel!.currentMessId, 
                          onFail: (message ) { 
                            showSnackber(context: context, content: "Entry Failed! \n$message");
                          },
                          onSuccess: (){ 
                            formKey.currentState!.reset();
                            showSnackber(context: context, content: "Entry Success!");
                          }, 
                        );
                        isUpdate = false;
                        titleController.clear();
                        amountController.clear();
                        descriptionController.clear();
      
                        setState(() {
                              
                        });
                      }
                    }
                    else{
                      showSnackber(context: context, content: "Fill All Required Field");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}