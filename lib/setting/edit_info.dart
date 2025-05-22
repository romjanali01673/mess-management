import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/services/asset_manager.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  GlobalKey<FormState> FormKey = GlobalKey<FormState>();
  bool checked = false;
  String Fname="";
  String Phone="";
  String Email="";

  File? finalFileImage;


  void updateInfo(){
    if(FormKey.currentState!.validate()){

    }
  }


  // select image 
  void selectImage({required bool fromCamera})async{
    File? selectedImage = await pickedImage(fromCamera: fromCamera, context: context, onFail: (message){
      showSnackber(context: context, content: message);
    });
    if(selectedImage!=null){
      // if the file exist the crop
      File? cropedImage = await cropImage(context, selectedImage.path);
      if(cropedImage!=null){
        // if the file has croped successfully and get existed url now we can do anything with it.
        debugPrint(cropedImage.path);
        finalFileImage = cropedImage;
        setState(() {
          
        });
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
    return Scaffold(
        appBar: AppBar(

        ),
        
        body: Container(
          child: Column(
            children: [
              Form(
                key: FormKey,
                child: Column(
                  children: [
            
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Do You Want To Edit?", style: TextStyle(fontSize: 25),),
                        ),
                        Checkbox(
                          value: checked, 
                          onChanged: (val){
                          setState(() {
                            checked = !checked;
                          });
                        }),
                      ],
                    ),
              
                    finalFileImage!=null?
                    Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              foregroundImage: finalFileImage==null? AssetImage(AssetsManager.userIcon) : FileImage(File(finalFileImage!.path)),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.black,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border : Border.all(color: Colors.white, width: 2),
                                  color: Colors.lightBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    // pick image from camera or galery
                                      showImagePickerDialog();
                                  },
                                ),
                              ),
                            ),
                          ],
                          )
                          :
                          Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              foregroundImage: finalFileImage==null? AssetImage(AssetsManager.userIcon) : FileImage(File(finalFileImage!.path)),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.black,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border : Border.all(color: Colors.white, width: 2),
                                  color: Colors.lightBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    // pick image from camera or galery
                                    setState(() {
                                      showImagePickerDialog();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                          ),
                    
                   Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey.shade300,
                                          border: Border(bottom: BorderSide(color: Colors.black))
                                        ),
                                        margin: EdgeInsets.all(10),
                                        child: TextFormField(
                                          enabled: checked,
                                          onChanged: (value){
                                            Fname = value.trim();
                                          },
                                          validator: (value) {
                                            if(Fname.length<4){
                                              return "Name should Contain at least 4 character";
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            label: Text("Full Name"),
                                            border: InputBorder.none,
                              
                                          ),
                                        ),
                                      ),
                        
                   Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey.shade300,
                                          border: Border(bottom: BorderSide(color: Colors.black))
                                        ),
                                        margin: EdgeInsets.all(10),
                                        child: TextFormField(
                                          enabled: checked,
                                          onChanged: (value){
                                            Email = value.trim();
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Email is required';
                                            }
                                            final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                            if (!pattern.hasMatch(value)) {
                                              return 'Enter a valid email';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            label: Text("Email"),
                                            border: InputBorder.none,
                              
                                          ),
                                        ),
                                      ),
                   Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey.shade300,
                                          border: Border(bottom: BorderSide(color: Colors.black))
                                        ),
                                        margin: EdgeInsets.all(10),
                                        child: TextFormField(
                                          
                                          enabled: checked,
                                          onChanged: (value){
                                            Phone = value.trim();
                                          },
                                          validator: (value) {
                                            // ^(?:\+88|88)? → allows optional country code +88 or 88.
                                            // 01[2-9] → valid operator codes (e.g., 013 to 019).
                                            // \d{8}$ → exactly 8 digits after the operator code (total 11 digits).
                                            final pattern = RegExp(r'^(?:\+88|88)?01[2-9]\d{8}$');
                                            if (value == null || value.isEmpty) {
                                              return 'Phone number is required';
                                            }
                                            if(!pattern.hasMatch(value.toString())){
                                              return "Enter Valid Phone Number";
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            label: Text("Phone"),
                                            border: InputBorder.none,
                                            hintText: "Enter Your Phone With Country Code"
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                      ),
                                      getButton(label: "Update", ontap: (){
                                        updateInfo();
                                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}