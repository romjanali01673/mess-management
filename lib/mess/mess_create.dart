import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/mess_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:provider/provider.dart';

class MessCreate extends StatefulWidget {
  const MessCreate({super.key});

  @override
  State<MessCreate> createState() => _MessCreateState();
}

class _MessCreateState extends State<MessCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); 

  TextEditingController messNameController = TextEditingController();
  TextEditingController messAddressController = TextEditingController();
  TextEditingController messOwnerNameController = TextEditingController();
  TextEditingController messOwnerIdController = TextEditingController();
  TextEditingController authorityPhoneController = TextEditingController();
  TextEditingController authorityEmailController = TextEditingController();

  @override
  void dispose() {
    messNameController.dispose();
    messAddressController.dispose();
    messOwnerNameController.dispose();
    messOwnerIdController.dispose();
    authorityPhoneController.dispose();
    authorityEmailController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding it is a class of randering,frame,layout ETC
    // instance create a instance of the class
    // addPostFrameCallback, the function will be called after fully building the screen.
    // (_) here will be given a duration but we dont't need the duration that's why we are ignoring using  underscore.
    WidgetsBinding.instance.addPostFrameCallback((_){
      final authProvider = context.read<AuthenticationProvider>();
      messOwnerIdController.text = authProvider.getUserModel!.uId;
      messOwnerNameController.text = authProvider.getUserModel!.fname;
    });
  }
  

  void _createMess()async{
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();
      messProvider.setIsloading(true);

      // stop process and show an dialog if user offline
      // if offline stop creations.
      if(!messProvider.isOnline) {
        showSnackber(context: context, content: "No Internet");
        messProvider.setIsloading(false);
        return;
      }

      // check are the member already connected to a mess.
      // if connected stop creations.
      if(authProvider.getUserModel!.currentMessId!=""){
        showSnackber(
          context: context, 
          content: "Already you are connected With a mess. \nTo create a new mess \nAt first you have to leave from current mess."
        );
        messProvider.setIsloading(false);
        return;
      }
    

      // store mess created info to firestore
      await messProvider.createMess(
        member: {
          Constants.fname: authProvider.getUserModel!.fname,
          Constants.uId: authProvider.getUserModel!.uId,
          Constants.status: Constants.enable,
        },
        messModel: MessModel(
          messId: DateTime.now().millisecondsSinceEpoch.toString(), 
          mealSessionId: DateTime.now().millisecondsSinceEpoch.toString(),
          messName: messNameController.text.toString().trim(), 
          messAddress: messAddressController.text.toString().trim(), 
          menagerId: authProvider.getUserModel!.uId.toString(), 
          actMenagerId: "", // secondary owner id will be published leter
          menagerName:authProvider.getUserModel!.fname.toString() , 
          actMenagerName: "", // secondary owner name will be published leter
          menagerPhone: authorityPhoneController.text.toString().trim(), 
          menagerEmail: authorityEmailController.text.toString().trim(),
          messMemberList: [
            {
              Constants.uId: authProvider.getUserModel!.uId.toString(),
              Constants.fname: authProvider.getUserModel!.fname.toString(),
              Constants.status: Constants.enable,
            }
          ],
        ),
        onFail: (message){
          showSnackber(context: context, content: "Mess Creation Failed.\n$message");
          messProvider.setIsloading(false);
        }, 
        onSuccess: (){
          // assign mess id to user model
          authProvider.getUserModel!.currentMessId = messProvider.getMessModel!.messId; 
          showSnackber(context: context, content: "Mess Has Created");
          messNameController.clear();
          messAddressController.clear();
          messOwnerIdController.clear();
          messOwnerNameController.clear();
          authorityPhoneController.clear();
          authorityEmailController.clear();
        }, 
      );

    }
    else showSnackber(context: context, content: "please fill all required Field");
  }

  @override
  Widget build(BuildContext context) {

    final authProvider = context.watch<AuthenticationProvider>();
    final messProvider = context.watch<MessProvider>();


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.amber.shade50,
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                spacing: 10,
                children: [
                  const Text("Welcome \nYou are going to create your own mess", textAlign: TextAlign.center,),
                  
                  FadeInUp(
                    duration: Duration(milliseconds: 100),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextFormField(
                        controller: messNameController,
                      // onTapOutside: (event) {// close keyboard
                        // FocusScope.of(context).unfocus();
                      // },
                      onChanged: (value){
                        // email = value.trim();
                      },
                      validator: (value) {
                        return nameValidator(value.toString());
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        label: Text("Mess Name"),
                        border: InputBorder.none,
                                      
                      ),
                    ),
                    ),
                  ),
              
                  FadeInUp(
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextFormField(
                        controller: messAddressController,
                      onChanged: (value){
      
                      },
                      // onTapOutside: (event) {// close keyboard
                        // FocusScope.of(context).unfocus();
                      // },
                      validator: (value) {
                        return addressValidator(value.toString());
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        label: Text("Mess Address"),
                        border: InputBorder.none,
                                      
                      ),
                    ),
                    ),
                  ),
              
                  FadeInUp(
                    duration: Duration(milliseconds: 600),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextFormField(
                        controller: messOwnerNameController,
                        // onTapOutside: (event) {// close keyboard
                        // FocusScope.of(context).unfocus();
                        // },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          enabled: false,
                          label: Text("Mess Owner Name"),
                          border: InputBorder.none,  
                        ),
                      ),
                    ),
                  ),
              
                  FadeInUp(
                    duration: Duration(milliseconds: 900),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextFormField(
                        controller: messOwnerIdController,
                        //   onTapOutside: (event) {// close keyboard
                        //   FocusScope.of(context).unfocus();
                        // },
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          enabled: false,
                          label: Text("Mess Owner Id"),
                          border: InputBorder.none,
                                      
                        ),
                      ),
                    ),
                  ),
              
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextFormField(
                      controller: authorityPhoneController,
                      // onTapOutside: (event) {// close keyboard
                      // FocusScope.of(context).unfocus();
                      // },
                      onChanged: (value){
                        // email = value.trim();
                      },
                      validator: (value) {
                        return numberVAladator(value.toString());
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        label: Text("Autrority Phone"),
                        border: InputBorder.none,
                                      
                      ),
                    ),
                    ),
                  ),
              
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextFormField(
                        controller: authorityEmailController,
                        // onTapOutside: (event) {// close keyboard
                        // FocusScope.of(context).unfocus();
                      // },
                      onChanged: (value){
                        // email = value.trim();
                      },
                      validator: (value) {
                        return emailValidator(value.toString().trim());
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        label: Text("Autrority Email"),
                        border: InputBorder.none,
                                      
                      ),
                    ),
                    ),
                  ),
            
                  messProvider.isLoading?
                  SizedBox.square(
                    dimension: 50,
                    child: CircularProgressIndicator()
                  )
                  : 
                  getMaterialButton(
                    context: context,
                    label: "Create", 
                    ontap:(){
                      _createMess();
                    }
                  )
      
                ],
              ),
            ),
          ),
        ),  
      ),
    );
  }
}