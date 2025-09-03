import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/home.dart';
import 'package:mess_management/model/user_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/services/asset_manager.dart';
import 'package:provider/provider.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  


  GlobalKey<FormState> FormKey = GlobalKey<FormState>();
  bool checked = false;
  

  File? finalFileImage;


  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void updateInfo()async{
    final authProvider = context.read<AuthenticationProvider>();
    if(FormKey.currentState!.validate() && checked){
      await authProvider.updateMemberEmail(
        preEmail: authProvider.getUserModel!.email,
        email: emailController.text.toString(),
        password: passController.text.toString(),
        onSuccess: (){
          showSnackber(context: context, content: "Update Successfully");
          setState(() {
            
          });
        }, 
        onFail: (message){
          showSnackber(context: context, content: "Update Failed! Try Again\n$message.");
        }, 
      );
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
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Email"),
        backgroundColor: Colors.grey,
      ),
        
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: authProvider.getMemberData(uId: authProvider.getUserModel!.uId),
            builder: (context, AsyncSnapshot<UserModel?> snapshot) { 
              if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                return Center(child: showCircularProgressIndicator());
              }
              else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } 
              else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('Data Not Found'));
              }
              emailController.text = snapshot.data!.email;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
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
                    
                          
                         Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Colors.grey.shade300,
                                                border: Border(bottom: BorderSide(color: Colors.black))
                                              ),
                                              margin: EdgeInsets.all(10),
                                              child: TextFormField(
                                                controller: emailController,
                                                enabled: checked,
                                                
                                                
                                                validator: (value) {
                                                  return emailValidator(value.toString());
                                                },
                                                keyboardType: TextInputType.text,
                                                textInputAction: TextInputAction.next,
                                                decoration: InputDecoration(
                                                  label: Text("New Email"),
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
                                                controller: passController,
                                                enabled: checked,
                                                
                                                
                                                validator: (value) {
                                                  return passValidator(value.toString());
                                                },
                                                keyboardType: TextInputType.text,
                                                textInputAction: TextInputAction.next,
                                                decoration: InputDecoration(
                                                  label: Text("Current Password"),
                                                  border: InputBorder.none,
                                    
                                                ),
                                              ),
                                            ),
                              
                         
                                            SizedBox(
                                              height: 40,
                                            ),
                        ],
                      ),
                    ),
                    getButton(label: "Update", ontap: (){
                      updateInfo();
                    }),
                  ],
                ),
              );
            }
          ),
        ),
    );
  }
}