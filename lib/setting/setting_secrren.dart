
import 'package:flutter/material.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/setting/edit_info.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool visibleCurrent = false;
  bool visibleNew = false;
  bool visibleConfirm = false;

  FocusNode FocusNodeCurrent = FocusNode();
  FocusNode FocusNodeNew = FocusNode();
  FocusNode FocusNodeConfirm = FocusNode();

  String currentPass="";
  String newPass="";
  String confirmPass="";



GlobalKey<FormState> formKey = GlobalKey<FormState>(); 


  bool valid(){
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();
      if( newPass == confirmPass){
        return true;
      }
      else{
        // show in snack new pass & confirm pass dosenot matching.
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
    return  Scaffold(
      
        body : Container(
          color: Colors.grey,
          height: double.infinity,
          width: double.infinity,
          child: ListView(
            children: [
              getItem(label: "Edit Profile", icon: Icons.edit, ontap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>EditInfo()));} ),
              getItem(label: "Security", icon: Icons.security, ontap: (){
                return showModalBottomSheet(
                  isScrollControlled: true,
                  context: context, 
                  builder: (BuildContext content){
                    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState){
                      return Container(
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
                                  focusNode: FocusNodeCurrent,
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).requestFocus(FocusNodeNew);
                                  },
                                  onChanged: (value){
                                    currentPass = value.trim();
                                  },
                                  validator: (value) {
                                    if(currentPass.length<8){
                                      return "password at least 8 character";
                                    }
                                    if(value.toString().contains(" ")){
                                      return "Space are Not Allowed";
                                    }
                                    return null;
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
                                        setModalState(() { // the setModalState work in "showModalBottomSheet"
                                          setState(() { // the setstate work in main page
                                            
                                          });
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
                                    if(newPass.length<8){
                                      return "password at least 8 character";
                                    }
                                    if(value.toString().contains(" ")){
                                      return "Space are Not Allowed";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    label: Text("New Password"),
                                    border: InputBorder.none,
                                    suffixIcon:
                                    IconButton(
                                      onPressed: (){ 
                                        setModalState(() { // the setModalState work in "showModalBottomSheet"
                                          setState(() { // the setstate work in main page
                                            
                                          });
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
                                    if(confirmPass.length<8){
                                      return "password at least 8 character";
                                    }
                                    if(value.toString().contains(" ")){
                                      return "Space are Not Allowed";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    label: Text("Confirm Password"),
                                    border: InputBorder.none,
                                    suffixIcon:
                                    IconButton(
                                      onPressed: (){ 
                                        setModalState(() { // the setModalState work in "showModalBottomSheet"
                                          setState(() { // the setstate work in main page
                                            
                                          });
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
                                onPressed: (){}, 
                                child: Text("Forgot Passwprd?", style: TextStyle(color: Colors.blue, fontSize: 16),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              getButton(label: "Submit", ontap: (){
                                valid();
                                print(currentPass);
                                print(newPass);
                                print(confirmPass);
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                    });
                });
              },
              ),
              getItem(label: "Logout", icon: Icons.logout, ),
            ],
          ),
        ),
    );
  }
}

Widget getItems({required String label, required IconData icon, Function()? ontap ,required bool selected}) {
  return GestureDetector(
    onTap: ontap ?? () {},
    child: Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(  // 💡 Let the whole row use max width if needed
            child: Row(
              children: [
                Icon(icon, size: 25),
                SizedBox(width: 8),
                Expanded(  // 💡 This makes text wrap or ellipsis
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis, // or .fade or .clip
                  ),
                ),
              ],
            ),
          ),
          selected ? Icon(Icons.ads_click, size: 20) : SizedBox.shrink(),
        ],
      ),
    ),
  );
}


Widget getItem({required String label, required IconData icon, Function()? ontap }){
  return GestureDetector(
    onTap: ontap??(){},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                Text(label)
              ]
            ),
          ),
        ),
      ),
  );
}









// "editor.codeActionsOnSave": {
//   "source.fixAll": true
// }

