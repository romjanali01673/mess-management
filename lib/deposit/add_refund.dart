import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/deposit_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/deposit_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class AddRefund extends StatefulWidget {
  const AddRefund({super.key});

  @override
  State<AddRefund> createState() => _AddRefundState();
}

class _AddRefundState extends State<AddRefund> {
  final formKey = GlobalKey<FormState>();
  final dropdownKey = GlobalKey<DropdownSearchState>();

  FocusNode focusDiscreption = FocusNode();
  FocusNode focusAmount = FocusNode();

  String discreption = ""; 
  String amount = ""; 

  List<String > list =[];
  // member uid|name
  Map<String,(String,String)> memberUidList={};
  String selectedItem = "Select Member";
  Set<String> disabledItems ={};


  Future<List<String>> _getAllMemberData()async{
    list.clear();
    disabledItems.clear();
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final messProvaider = context.read<MessProvaider>();
    final authProvaider = context.read<AuthenticationProvider>();
    await messProvaider.getMessData(
      onFail: (message){

      }, 
      messId:authProvaider.getUserModel!.currentMessId,
    );

    if(messProvaider.getMessModel==null) return list;
    for(dynamic member in messProvaider.getMessModel!.messMemberList){
      try {
        
          list.add("Name: ${member[Constants.fname]} \nId: ${member[Constants.uId]}");
          memberUidList["Name: ${member[Constants.fname]} \nId: ${member[Constants.uId]}"] = (member[Constants.uId],member[Constants.fname]);//(uid,name)
          if(member[Constants.status]==Constants.disable){
            disabledItems.add("Name: ${member[Constants.fname]} \nId: ${member[Constants.uId]}");
          }
        
      } catch (e) {
        showSnackber(context: context, content: e.toString());
      }
    }
    return list;
  }
  


  @override
  Widget build(BuildContext context) {
    final depositProvaider = context.watch<DepositProvaider>();
    final messProvaider = context.watch<MessProvaider>();
    final authProvaider = context.watch<AuthenticationProvider>();

    return Expanded(
      child: Container(
        color: Colors.green.shade50,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
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
              ),
        
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        autofocus: true,
                        focusNode: focusDiscreption,
                        onFieldSubmitted: (value){
                          FocusScope.of(context).requestFocus(focusAmount);
                        },
                        // validator: (value) {
                        //   if(value.toString().trim()==""){
                        //     return "";
                        //   }
                        //   return null;
                        // },
                        onChanged: (value) {
                          amount = value.trim();
                        },
                        decoration: FromFieldDecoration(
                          hintText: "Write About The Deposit",
                          label: "Discreption (Optional)",
                        )
                      ),
                    ),
                
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        focusNode: focusAmount,
                        onFieldSubmitted: (value){
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          return validatePrice(value.toString());
                        },
                        onChanged: (value) {
                          amount = value.trim();
                        },
                        decoration: FromFieldDecoration(
                          hintText: "How Much?",
                          label: "Amount",
                        )
                      ),
                    ),
                  ],
                )
              ),             
              SizedBox(
                height: 50,
              ),
              getButton(
                label: "Submit", 
                ontap: ()async{

                  bool valided  = (formKey.currentState!.validate() && selectedItem!="Select Member");
                  
                  if(valided){
                    await depositProvaider.addADepositTransaction(
                      depositModel: DepositModel(
                        transactionId: DateTime.now().millisecondsSinceEpoch.toString(), 
                        amount: double.parse(amount), 
                        description: discreption, 
                        type: Constants.refund, 
                      ), 
                      uId: memberUidList[selectedItem]!.$1, 
                      messId: authProvaider.getUserModel!.currentMessId, 
                      onFail: (message ) { 
                        showSnackber(context: context, content: "Refund Failed! \n$message");
                      },
                      onSuccess: (){ 
                        formKey.currentState!.reset();
                        showSnackber(context: context, content: "Refund Success!");
                      }
                    );
                    setState(() {
                          
                    });
                  }
                  else{
                    showSnackber(context: context, content: "Fill All Required Field");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}