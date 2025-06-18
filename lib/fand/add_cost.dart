import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/fand_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/fand_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class AddCost extends StatefulWidget {
  const AddCost({super.key});

  @override
  State<AddCost> createState() => _AddCostState();
}

class _AddCostState extends State<AddCost> {
  final formKey = GlobalKey<FormState>();

  FocusNode focusTitle = FocusNode();
  FocusNode focusDiscreption = FocusNode();
  FocusNode focusAmount = FocusNode();

  String title = "";
  String description = ""; 
  double amount = 0; 


  @override
  Widget build(BuildContext context) {

    FandProvider fandProvider = context.watch<FandProvider>();
    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();

    return Expanded(
      child: Container(
        color: Colors.red.shade50,
        child:  Form(
          key: formKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
                    
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    focusNode: focusTitle,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).requestFocus(focusDiscreption);
                    },
                    validator: (value) {
                      if(value.toString().trim()==""){
                        return "";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      title = value.trim();
                    },
                    decoration: FromFieldDecoration(
                      hintText: "Title",
                      label: "Title",
                    )
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    focusNode: focusDiscreption,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).requestFocus(focusAmount);
                    },
                    validator: (value) {
                      return null;
                    },
                    onChanged: (value) {
                      description = value.trim();
                    },
                    decoration: FromFieldDecoration(
                      hintText: "Write Details about",
                      label: "Description (optional)",
                    )
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    focusNode: focusAmount,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).unfocus();
                    },
                    validator: (value) {
                      if(value.toString().trim()==""){
                        return "";
                      }
                      try {
                        amount = double.parse(value.toString().trim());
                      } catch (e) {
                        return e.toString();
                      }
                      return null;
                    },
                    onChanged: (value) {
                      try {
                        amount = double.parse(value.toString().trim());
                      } catch (e) {
                        //
                      }
                    },
                    decoration: FromFieldDecoration(
                      hintText: "How Much?",
                      label: "Amount",
                    )
                  ),
                ),
            
                SizedBox(
                  height: 50,
                ),
            
                fandProvider.isLoading? 
                SizedBox.square(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
                :
                getButton(
                  label: "Submit", 
                  ontap: ()async{
                    bool valided  = formKey.currentState!.validate();
                    if(valided){
                      if(amIAdmin(messProvider: context.read<MessProvider>(), authProvider:context.read<AuthenticationProvider>(),)){
                        // add a transaction to datebase 
                        await fandProvider.addAFandTransaction(
                          fandModel: FandModel(
                            transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
                            amount: amount,
                            title: title,
                            description: description, 
                            // CreatedAt: DateTime.now().millisecondsSinceEpoch.toString(), 
                            type: Constants.sub
                          ), 
                          messId: authProvider.getUserModel!.currentMessId,
                          onSuccess: (){
                            fandProvider.setIsLoading(value: false);
                            showSnackber(context: context, content: "Entry Successed");
                          }, 
                          onFail: (message){
                            fandProvider.setIsLoading(value: false);
                            showSnackber(context: context, content: "Entry Failed!\n$message");
                          },
                        );
                      }
                      else{
                        showSnackber(context: context, content: "required meneger power");
                      }
                    }
                    else{
                      showSnackber(context: context, content: "please, fill add required field!");
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