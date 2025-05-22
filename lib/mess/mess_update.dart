import 'package:animate_do/animate_do.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class MessUpdate extends StatefulWidget {
  const MessUpdate({super.key});

  @override
  State<MessUpdate> createState() => _MessUpdateState();
}

class _MessUpdateState extends State<MessUpdate> {
  bool transferOwnership = false;

  final dropdownKey = GlobalKey<DropdownSearchState>();
  List<String> items = ["romjan", "siam", "sayed"];
  String selectedItem = "Select Member";
  Set<String> disabledItems ={"sayed"};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding it is a class of randering,frame,layout ETC
    // instance create a instance of the class
    // addPostFrameCallback, the function will be called after fully building the screen.
    // (_) here will be given a duration but we dont't need the duration that's why we are ignoring using  underscore.
    WidgetsBinding.instance.addPostFrameCallback((_){
      // showMessageDialog(
      //   context: context, 
      //   title: "Note:", 
      //   Discreption: "To Create your own mess, \nyou have to leave from previous mess. \nif you was joined yet.",
      // );
    });
  }
  
  @override
  Widget build(BuildContext context) {
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
                label: "Update", 
                ontap:(){
              
                }
              )
          
            ],
          ),
        ),
      ),
    );
  }

  Widget getTransferOwnershipData(){
    return Container(
              margin: EdgeInsets.all(10),
              child: DropdownSearch<String>(
                key: dropdownKey, // Needed for reset
                items: items,
                
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
                    setState(() {
                      selectedItem = value.toString();
                    });
                    debugPrint("Selected enable: $value");
                  }
                },
              ),
            );
  }

  Widget getInfoForUpdateMess(){
    return Column(
      spacing: 10,
      children: [
        FadeInUp(
          duration: Duration(milliseconds: 100),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextFormField(
            onChanged: (value){
              // email = value.trim();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!pattern.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
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
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextFormField(
            onChanged: (value){
              // email = value.trim();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!pattern.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
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
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextFormField(
            onChanged: (value){
              // email = value.trim();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Owner name required';
              }
              final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!pattern.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
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
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextFormField(
            onChanged: (value){
              // email = value.trim();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!pattern.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
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
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextFormField(
            onChanged: (value){
              // email = value.trim();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!pattern.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
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
              color: Colors.amber.shade300,
              borderRadius: BorderRadius.circular(10)
            ),
            child: TextFormField(
            onChanged: (value){
              // email = value.trim();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!pattern.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              label: Text("Autrority Email"),
              border: InputBorder.none,
                            
            ),
          ),
          ),
        ),
      ],
    );
  }
}