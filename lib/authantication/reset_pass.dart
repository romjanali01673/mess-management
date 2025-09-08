import 'package:flutter/material.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:provider/provider.dart';

class RestPass extends StatefulWidget {
  const RestPass({super.key});

  @override
  State<RestPass> createState() => _RestPassState();
}

class _RestPassState extends State<RestPass> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
        backgroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        ),
                        height: 500,
                        width: double.infinity,
                        child: SingleChildScrollView(
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
                                    controller: emailController,
                                    validator: (value) {
                                      return emailValidator(value.toString());
                                    },
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      label: Text("Email"),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                
                                getButton(
                                  ontap: (){
                                    if(formKey.currentState!.validate()){
                                      final authProvider = context.read<AuthenticationProvider>();
                                      authProvider.forgetPassword(email:emailController.text.toString());
                                      showMessageDialog(context: context, title: "Rest Message", Discreption: "Password Rest message has send to your given email address, please check in spam folder if not found in primary email section.");
                                    }
                                  }, 
                                  label: "Reset" ,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                      ),
        ],
      ),
    );
  }
}