import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class AddMemberScreen extends StatefulWidget{
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen>createState()=> _AddMemberScreenState();

}

class _AddMemberScreenState extends State<AddMemberScreen>{
  var searchController = TextEditingController();
  bool found = false;

  @override
  void dispose() {
    searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
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
                  ElevatedButton(
                    onPressed: ()async{
                      found = false;
                      found = await showConfirmDialog(context: context, title: "xyz");
                      setState(() {
                        
                      });
                    }, 
                    child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("search"),
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
                    Text("name :"),
                    Expanded(
                      child: Text("md romjan\n\n\n\n\n\n\na ali")
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Id :"),
                    Expanded(
                      child: Text("md romjana ali")
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phone :"),
                    Expanded(
                      child: Text("md romjana ali")
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email :"),
                    Expanded(
                      child: Text("md romjana ali")
                    )
                  ],
                ),
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email :"),
                    Expanded(
                      child: Text("md romjana ali")
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Text("Address :"),
                    Expanded(
                      child: Text("md romjana ali")
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