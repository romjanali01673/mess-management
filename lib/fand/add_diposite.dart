import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/fand_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/fand_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class AddDiposite extends StatefulWidget {
  const AddDiposite({super.key});

  @override
  State<AddDiposite> createState() => _AddDipositeState();
}

class _AddDipositeState extends State<AddDiposite> {
  final formKey = GlobalKey<FormState>();

  FocusNode focusTitle = FocusNode();
  FocusNode focusDiscreption = FocusNode();
  FocusNode focusAmount = FocusNode();

  String title = "";
  String description = ""; 
  double amount = 0; 


  File? finalImageFile;
  // select image 
  void selectImage({required bool fromCamera})async{
    finalImageFile = await pickedImage(fromCamera: fromCamera, context: context, onFail: (message){
      showSnackber(context: context, content: message);
    });
    if(finalImageFile!=null){
      // if the file exist the crop
      File? f = await cropImage(context, finalImageFile!.path);
      if(f!=null){
        // if the file has croped successfully and get existed url now we can do anything with it.
        debugPrint(f.path);
        finalImageFile = f;
      }
    }
  }

  // this function just show wanted dialog box
  void showImagePickerDialog(){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text("Choos From:"),
      scrollable: true,
      content: Column(
        children: [
          ListTile(
            title: Text("Camera"),
            leading: FaIcon(FontAwesomeIcons.camera),
            onTap: () {
              selectImage(fromCamera: true);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Gellary"),
            leading: FaIcon(FontAwesomeIcons.images),
            onTap: () {
              selectImage(fromCamera: false);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      actions: [],
    ));
  }

  @override
  Widget build(BuildContext context) {

    FandProvaider fandProvaider = context.watch<FandProvaider>();
    AuthenticationProvider authProvaider = context.read<AuthenticationProvider>();
    
    return Expanded(
      child: Container(
        color: Colors.green.shade50,
        child: Form(
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
                      label: "Description",
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
            
                fandProvaider.isLoading? 
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
                      if(amIAdmin(messProvaider: context.read<MessProvaider>(), authProvaider:context.read<AuthenticationProvider>(),)){
                        // add a transaction to datebase 
                        await fandProvaider.addAFandTransaction(
                          fandModel: FandModel(
                            transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
                            amount: amount,
                            title: title,
                            description: description, 
                            type: Constants.add
                          ), 
                          messId: authProvaider.getUserModel!.currentMessId,
                          onSuccess: (){
                            fandProvaider.setIsLoading(value: false);
                            showSnackber(context: context, content: "Entry Successed");
                          }, 
                          onFail: (message){
                            fandProvaider.setIsLoading(value: false);
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


// fand -> mess_id -> transactions -> transaction_id ->  {id, amount, title, description, time, type{"add", "sub"}, }