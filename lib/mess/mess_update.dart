import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/mess_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class MessUpdate extends StatefulWidget {
  const MessUpdate({super.key});

  @override
  State<MessUpdate> createState() => _MessUpdateState();
}

class _MessUpdateState extends State<MessUpdate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool transferOwnership = false;
  TextEditingController messNameController = TextEditingController();
  TextEditingController messAddressController = TextEditingController();
  TextEditingController messOwnerNameController = TextEditingController();
  TextEditingController messOwnerIdController = TextEditingController();
  TextEditingController authorityPhoneController = TextEditingController();
  TextEditingController authorityEmailController = TextEditingController();

  final dropdownKey = GlobalKey<DropdownSearchState>();
  List<String > list =["wqer","qwe"];
  // member uid|name
  Map<String,(String,String)> memberUidList={};
  String selectedItem = "Select Member";
  Set<String> disabledItems ={};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding it is a class of randering,frame,layout ETC
    // instance create a instance of the class
    // addPostFrameCallback, the function will be called after fully building the screen.
    // (_) here will be given a duration but we dont't need the duration that's why we are ignoring using  underscore.
    WidgetsBinding.instance.addPostFrameCallback((_){
      final messProvaider = context.read<MessProvaider>();
      final authProvaider = context.read<AuthenticationProvider>();
      messProvaider.getMessData(
        messId: authProvaider.userModel!.currentMessId,
        onFail: (message){
          showSnackber(context: context, content: message);
        }, 
        onSuccess: (){
          messOwnerIdController.text = authProvaider.userModel!.createdAt;
          messOwnerNameController.text = messProvaider.getMessModel!.messAuthorityName;
          messNameController.text = messProvaider.getMessModel!.messName;
          messAddressController.text = messProvaider.getMessModel!.messAddress;
          authorityPhoneController.text = messProvaider.getMessModel!.messAuthorityNumber;
          authorityEmailController.text = messProvaider.getMessModel!.messAuthorityEmail;
        }
      );
    });
  }
  
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

  bool amIAdmin(){
    final messProvaider = context.read<MessProvaider>();
    final authProvaider = context.read<AuthenticationProvider>();
    if(messProvaider.getMessModel!=null){
      if(messProvaider.getMessModel!.messAuthorityId == authProvaider.userModel!.uId){
        return true;
      }
      else{
        showSnackber(context: context, content:"required Authority power");
        return false;
      }
    }
    else{
      showSnackber(context: context, content: "you are not in any mess");
      return false;
    }
  } 

  @override
  Widget build(BuildContext context) {
    final messProvaider = context.watch<MessProvaider>();

    return Expanded(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.amber.shade100,
        padding: EdgeInsets.all(4),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            spacing: 10,
            children: [
              const Text("Note \nYou are going to Update your mess.", textAlign: TextAlign.center,),
              Row(
                children: [
                  const Text("Transfer Ownership-"),
                  Switch(
                    value: transferOwnership, 
                    onChanged: (val){
                      setState(() {
                        transferOwnership = val;
                      });
                    }
                  ),
                ],
              ),
              
          
              transferOwnership? getTransferOwnershipData()
              :
              getInfoForUpdateMess(),
              
          
              getMaterialButton(
                context:context,
                label: "Update", 
                ontap:()async{
                  if(amIAdmin()){
                    if(transferOwnership){
                      bool? res =await showConfirmDialog(context: context, title: "you are going to transfer \nyour administrator power. \nAre you sure about this Update.");
                      if(res ?? false){
                        // transfer ownership
                        if(selectedItem!="Select Member"){
                          messProvaider.transferMessOwnership(
                            adminId: memberUidList[selectedItem]!.$1, 
                            adimnName: memberUidList[selectedItem]!.$2, 
                            onFail: (message){
                              showSnackber(context: context, content: "Updatation Failed \n$message");
                            },
                            onSuccess: (){
                              showSnackber(context: context, content: "Updatation Successfully.");
                            },
                          );
                        }
                        else{
                          showSnackber(context: context, content: "At First Select Member");
                        }
                      }
                    }
                    else{
                      if(formKey.currentState!.validate()){
                        bool? res =await showConfirmDialog(context: context, title: "Are you sure about this Update.");
                        if(res?? false){
                          // update mess data
                          messProvaider.updateMessDataToFirestore(
                            onFail: (message){
                              showSnackber(context: context, content: message);
                            }, 
                            messModel: MessModel(
                              messId: "", 
                              messName: messNameController.text.toString(), 
                              messAddress: messAddressController.text.toString(), 
                              messAuthorityId: "", 
                              messAuthorityId2nd: "", 
                              messAuthorityName: "", 
                              messAuthorityName2nd: "", 
                              messAuthorityNumber: authorityPhoneController.text.toString(), 
                              messAuthorityEmail: authorityEmailController.text.toString(), 
                              messMemberList: [],
                              disabledMemberList: [],
                            ),
                            onSuccess: (){
                              showSnackber(context: context, content: "Updatation Success.");
                            }
                          );
                        }
                      }
                      else{
                        showSnackber(context: context, content: "fill all required field");
                      }
                    }
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getAllMemberData()async{
    list.clear();
    disabledItems.clear();
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final messProvaider = context.read<MessProvaider>();
    
    if(messProvaider.getMessModel==null) return list;
    for(String uid in messProvaider.getMessModel!.messMemberList){
      try {
        DocumentSnapshot documentSnapshot = await firebaseFirestore
          .collection(Constants.users)
          .doc(uid)
          .get();
        if(documentSnapshot.exists){
          list.add("Name: ${documentSnapshot[Constants.fname]} \nId: ${documentSnapshot[Constants.createdAt]}");
          memberUidList["Name: ${documentSnapshot[Constants.fname]} \nId: ${documentSnapshot[Constants.createdAt]}"] = (uid,documentSnapshot[Constants.fname]);//(uid,name)
          if(messProvaider.getMessModel!.disabledMemberList.contains(uid)){
            disabledItems.add("Name: ${documentSnapshot[Constants.fname]} \nId: ${documentSnapshot[Constants.createdAt]}");
          }
        }

      
      } catch (e) {
        showSnackber(context: context, content: e.toString());
      }
    }
    return list;
  }

  Widget getTransferOwnershipData(){
    return Container(
              margin: EdgeInsets.all(10),
              // child: FutureBuilder(
              //   future: future, 
              //   builder: builder,
              // ),
              child: DropdownSearch<String>(
                key: dropdownKey, // Needed for reset
                asyncItems: (String filter) => _getAllMemberData(),
                selectedItem: selectedItem,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select Member",
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                      
                  // Disable specific item visually and functionally
                  itemBuilder: (context, item, isSelected) {
                    bool isDisabled = disabledItems.contains(item);
                    return IgnorePointer(
                      ignoring: isDisabled,
                      child: ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            color: isDisabled ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // always use this function it's tested
                // otherwise we get error because there are few bug here
                onChanged: (value) {
                  if (value != null && disabledItems.contains(value)) {
                  // Reset visually and logically
                    dropdownKey.currentState?.clear(); // clears the selection
                    debugPrint("Selected disable: $selectedItem");                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("This Member is disabled.")),
                    );
                  } 
                  else {
                    if(value!=null){
                      // here we receive only enabled value.
                      setState(() {
                        selectedItem = value.toString();
                      });
                      debugPrint("Selected enable: $value");
                    }
                  }
                },
              ),
            );
  }

  Widget getInfoForUpdateMess(){
    return Form(
      key: formKey,
      child: Column(
        spacing: 10,
        children: [
          
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
        ],
      ),
    );
  }
}




// Image
// whatsapp
// github - white
// linked - white 
// summary -right 
// education - right 
// communication
// project left 