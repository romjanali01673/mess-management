import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/mess_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/service_provaider.dart';
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
      final authProvaider = context.read<AuthenticationProvider>();
      messOwnerIdController.text = authProvaider.userModel!.createdAt;
      messOwnerNameController.text = authProvaider.userModel!.fname;
    });
  }
  

  void _createMess(){
    final serviceProvaider = context.read<ServiceProvaider>();
    final authProvaider = context.read<AuthenticationProvider>();
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();

      // store mess info to firestore
      serviceProvaider.storeMessDataToFirestore(
        onFail: (message){
          showSnackber(context: context, content: message);
        }, 
        messModel: MessModel(
          messId: "", 
          messName: messNameController.text.toString(), 
          messAddress: messAddressController.text.toString(), 
          messAuthorityId: authProvaider.userModel!.uId.toString(), 
          messAuthorityId2nd: "", // secondary owner id will be published leter
          messAuthorityName:authProvaider.userModel!.fname.toString() , 
          messAuthorityName2nd: "", // secondary owner name will be published leter
          messAuthorityNumber: authorityPhoneController.text.toString(), 
          messAuthorityEmail: authorityEmailController.text.toString(),
        )
      );

    }
    else showSnackber(context: context, content: "please fill all required Field");
  }

  @override
  Widget build(BuildContext context) {

    final authProvaider = context.watch<AuthenticationProvider>();
    final serviceProvaider = context.watch<ServiceProvaider>();


    return Expanded(
      child: Padding(
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
                    onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
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
                    onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
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
                      onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                      },
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
                      onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
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
                      onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
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
                      onTapOutside: (event) {// close keyboard
                      FocusScope.of(context).unfocus();
                    },
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
          
                serviceProvaider.isLoading?
                SizedBox.square(
                  dimension: 50,
                  child: CircularProgressIndicator()
                )
                : 
                getMaterialButton(
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
    );
  }
}