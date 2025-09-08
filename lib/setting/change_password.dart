import 'package:flutter/material.dart';
import 'package:mess_management/authantication/reset_pass.dart';
import 'package:mess_management/authantication/sign_in.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  bool visibleCurrent = false;
  bool visibleNew = false;
  bool visibleConfirm = false;

  FocusNode FocusNodeCurrent = FocusNode();
  FocusNode FocusNodeNew = FocusNode();
  FocusNode FocusNodeConfirm = FocusNode();

  String currentPass="";
  String newPass="";
  String confirmPass="";


  bool valid(BuildContext innerContext){
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();
      if( newPass == confirmPass){
        return true;
      }
      else{
        showSnackber(context: context, content: "Confirm Password Not Matched");
      }
    }
    return false;
  }
    
  @override
  void dispose() {
    // TODO: implement dispose
    FocusNodeCurrent.dispose();
    FocusNodeNew.dispose();
    FocusNodeConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Change Password"),
          backgroundColor: Colors.grey,
        ),      
        body: SingleChildScrollView(
         scrollDirection: Axis.vertical,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
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
                    focusNode: FocusNodeCurrent,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(FocusNodeNew);
                    },
                    onChanged: (value){
                      currentPass = value.trim();
                    },
                    validator: (value) {
                      return passValidator(value.toString());
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    obscureText: visibleCurrent,
                    decoration: InputDecoration(
                      label: Text("Current Password"),
                      border: InputBorder.none,
                      suffixIcon:
                      IconButton(
                        onPressed: (){ 
                           // the setModalState work in "showModalBottomSheet"
                          setState(() { // the setstate work in main page
                            visibleCurrent = !visibleCurrent;
                          });
                          
                        }, 
                        icon: visibleCurrent? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                      ),
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
                    focusNode: FocusNodeNew,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).requestFocus(FocusNodeConfirm);
                    },
                    textInputAction: TextInputAction.next,
                    obscureText: visibleNew,
                    keyboardType: TextInputType.text,
                    onChanged: (value){
                      newPass = value.trim();
                    },
                    validator: (value) {
                      return passValidator(value.toString());
                    },
                    decoration: InputDecoration(
                      label: Text("New Password"),
                      border: InputBorder.none,
                      suffixIcon:
                      IconButton(
                        onPressed: (){ 
                            setState(() { // the setstate work in main page
                              
                            visibleNew = !visibleNew;
                            });
                        }, 
                        icon: visibleNew? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                      ),
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
                    focusNode: FocusNodeConfirm,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).unfocus();
                    },
                    textInputAction: TextInputAction.done,
                    obscureText: visibleConfirm,
                    keyboardType: TextInputType.text,
                    onChanged: (value){
                      confirmPass = value.trim();
                    },
                    validator: (value) {
                      return passValidator(value.toString());
                    },
                    decoration: InputDecoration(
                      label: Text("Confirm Password"),
                      border: InputBorder.none,
                      suffixIcon:
                      IconButton(
                        onPressed: (){ 
                            setState(() { // the setstate work in main page
                              
                            visibleConfirm = !visibleConfirm;
                            });
                        }, 
                        icon: visibleConfirm? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RestPass()));
                  }, 
                  child: Text("Forgot Passwprd?", style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Consumer<AuthenticationProvider>(
                  builder: (context, authProvider, child){
                    return authProvider.isLoading?
                    showCircularProgressIndicator()
                    :
                    getButton(label: "Submit", 
                      ontap: ()async{
                        if(valid(context)){
                          // all valid noe change password.
                          await authProvider.changePassword(
                            currentPass: currentPass, 
                            newPass: newPass,
                            onFail: (message) {
                              showSnackber(context: context, content: "$message");
                            },
                            onSuccess: (){
                              showSnackber(context: context, content: "Password Changed Success");
                              Navigator.of(context).pop();
                              formKey.currentState!.reset();
                            }
                          );
                        }
                      }
                    );
                  }
                ),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}