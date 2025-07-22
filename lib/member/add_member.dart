import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/joining_model.dart';
import 'package:mess_management/model/user_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class AddMemberScreen extends StatefulWidget{
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen>createState()=> _AddMemberScreenState();

}

class _AddMemberScreenState extends State<AddMemberScreen>{
  final GlobalKey<FormState> fromKey = GlobalKey<FormState>();
  var searchController = TextEditingController();
  bool found = false;
  UserModel? userModel;

  @override
  void dispose() {
    searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    final messProvider = context.watch<MessProvider>();
    final authProvider = context.watch<AuthenticationProvider>();
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 230, 219, 186),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(

                    child: Form(
                      key: fromKey,
                      child: TextFormField(
                            validator: (value) {
                          return validateUid(value.toString());
                          },
                            controller: searchController,
                            keyboardType: TextInputType.number,
                            // onTapOutside: (event) {// close keyboard
                              // FocusScope.of(context).unfocus();
                            // },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Only allows digits
                            ],
                            decoration: InputDecoration(
                              label: Text("Id No:"),
                              // helperText: "helper Text 1",
                              prefix: Icon(Icons.man),
                              // suffix: InkWell(child: Icon(Icons.abc), onTap:() => print("hi ${text1.text.toString()}"),),
                              hintText: "Search Member by Id!",
                              // filled: true,
                              fillColor: Colors.red.shade100,
                              // errorText: "you must have to Enter your Name",
                              border: OutlineInputBorder(// if we use enable/disable/focused border we can ignore normal order
                                  borderSide: BorderSide(
                                  color:Colors.red,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              
                              errorBorder: OutlineInputBorder(
                      
                              )
                            ),
                      
                          ),
                    ),
                  ),
                  messProvider.isLoading? CircularProgressIndicator() 
                  : 
                  ElevatedButton(
                    onPressed: ()async{
                      // clear pre data
                      setState(() {
                        found = false;
                        userModel = null;
                      });


                      if(amIAdmin(messProvider: messProvider, authProvider: authProvider)){
                        if(fromKey.currentState!.validate()){
                          messProvider.setIsloading(true);
                          UserModel? memberData =  await authProvider.getMemberData(uId: searchController.text.toString().trim());
                          messProvider.setIsloading(false);

                          if(memberData==null){
                          showSnackber(context: context, content: "No Data Found!");
                          }
                          else{
                            setState(() {
                              userModel = memberData;
                              found = true;
                            });
                          }
                        }
                        
                      }
                      else{
                        showSnackber(context: context, content: "You are not mess menager");
                      }
                      
                    }, 
                    child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child:Text("search"),
                  ),)
                ],
              ),
            ),
            found ? Column(
              spacing: 20,
              children: [
                
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name :",
                      style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(userModel!.fname)
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Id :",
                      style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(userModel!.uId)
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phone :",
                      style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(userModel!.number)
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email :",
                      style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(userModel!.email)
                    )
                  ],
                ),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Text("Address :",
                      style: getTextStyleForSubTitleL().copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(userModel!.fullAddress)
                    )
                  ],
                ),SizedBox(
                  height: 40,
                ),

                messProvider.isLoading? showCircularProgressIndicator():
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    getMenuItems(label: "Clear", ontap: (){
                      setState(() {
                        searchController.clear();
                        userModel = null;
                        found=false;
                      });
                      //clear all variable or data
                    }),
                    
                    getMenuItems(label: "Invite", ontap: ()async{
                      bool confirm = await showConfirmDialog(context: context, title: "Are your Sure to About this invitation");
                      if(confirm){
                        searchController.clear();
                        messProvider.setIsloading(true);
                        await messProvider.sendMessInvaitaionCard(
                          memberUid: userModel!.uId, 
                          joiningModel:JoiningModel(
                            invaitationId: DateTime.now().millisecondsSinceEpoch.toString(), 
                            messName: messProvider.getMessModel!.messName, 
                            messId: messProvider.getMessModel!.messId, 
                            status: JoiningStatus.pending, 
                            description: "Hello ${userModel!.fname}! \nWe’re inviting you to become a member of our mess. We work together to manage meals, expenses, and a smooth daily routine. Hope you’ll join us!", 
                            messAddress: messProvider.getMessModel!.messAddress, 
                          ),
                          onSuccess:(){
                            messProvider.setIsloading(false);
                            userModel = null;
                            found=false;
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              showSnackber(context: context, content: "Invaitations Message has send Successfully");
                            },);
                          },
                          onFail: (message) {
                            showSnackber(context: context, content: message);
                          },
                        );
                        messProvider.setIsloading(false);
                      }
                      found=false;
                    }),
                  ],
                ),
              ],
            )
            :
            SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}