import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/user_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class AddMemberScreen extends StatefulWidget{
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen>createState()=> _AddMemberScreenState();

}

class _AddMemberScreenState extends State<AddMemberScreen>{
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
    final messProvaider = context.watch<MessProvaider>();
    final authProvaider = context.watch<AuthenticationProvider>();
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
                    child: TextField(
                          autofocus: false,
                          controller: searchController,
                          enabled: true,
                          obscureText: false,
                          obscuringCharacter: '*',
                          keyboardType: TextInputType.number,
                          onTapOutside: (event) {// close keyboard
                            FocusScope.of(context).unfocus();
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Only allows digits
                          ],
                          decoration: InputDecoration(
                            label: Text("Id No:"),
                            // helperText: "helper Text 1",
                            prefix: Icon(Icons.man),
                            // suffix: InkWell(child: Icon(Icons.abc), onTap:() => print("hi ${text1.text.toString()}"),),
                            hintText: "Search Member by Id!",
                            // filled: true,÷\
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
                  messProvaider.isLoading? CircularProgressIndicator() 
                  : 
                  ElevatedButton(
                    onPressed: ()async{
                      // clear pre data
                      setState(() {
                        found = false;
                        userModel = null;
                      });

                      if(searchController.text.toString().trim().length != authProvaider.userModel!.uId.length){
                        showSnackber(context: context, content: "Invalid Argument!");
                        return;
                      }
                      messProvaider.setIsloading(true);
                      UserModel? memberData =  await messProvaider.getMemberData(uId: searchController.text.toString().trim());
                      messProvaider.setIsloading(false);
                      if(memberData==null){
                        showSnackber(context: context, content: "No Data Found!");
                        return;
                      }
                      else{
                        // data found
                        setState(() {
                          userModel = memberData;
                          found = true;
                        });
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
                    Text("Name :"),
                    Expanded(
                      child: Text(userModel!.fname)
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Id :"),
                    Expanded(
                      child: Text(userModel!.uId)
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phone :"),
                    Expanded(
                      child: Text(userModel!.number)
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email :"),
                    Expanded(
                      child: Text(userModel!.email)
                    )
                  ],
                ),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Text("Address :"),
                    Expanded(
                      child: Text(userModel!.fullAddress)
                    )
                  ],
                ),SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    getMenuItems(label: "Clear", ontap: (){
                      searchController.clear();
                      found=false;
                      //clear all variable or data
                    }),
                    getMenuItems(label: "Invite", ontap: ()async{
                      bool confirm = await showConfirmDialog(context: context, title: "Are your Sure to About this invitation");
                      searchController.clear();
                      found=false;
                      if(confirm){
                        //clear all variable or data and show a snack message

                        // show the message has send success/fail message
                      }
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