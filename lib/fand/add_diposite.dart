import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class AddDiposite extends StatefulWidget {
  const AddDiposite({super.key});

  @override
  State<AddDiposite> createState() => _AddDipositeState();
}

class _AddDipositeState extends State<AddDiposite> {
  final formKey = GlobalKey<FormState>();

  FocusNode focusDiscreption = FocusNode();
  FocusNode focusAmount = FocusNode();

  String discreption = ""; 
  String amount = ""; 


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
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    autofocus: true,
                    focusNode: focusDiscreption,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).requestFocus(focusAmount);
                    },
                    validator: (value) {
                      if(value.toString().trim()==""){
                        return "";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      amount = value.trim();
                    },
                    decoration: FromFieldDecoration(
                      hintText: "Write About The Diposite",
                      label: "Discreption",
                    )
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 1,
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
                      return null;
                    },
                    onChanged: (value) {
                      amount = value.trim();
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
            
                getButton(
                  label: "Submit", 
                  ontap: (){
                    bool valided  = formKey.currentState!.validate();
                    if(valided){
                      setState(() {
                            
                      });
                    }
                    else{
                      showImagePickerDialog();
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