

import 'package:flutter/material.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/rule_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class AddRule extends StatefulWidget {
  final RuleModel? preRuleModel;
  const AddRule({super.key, this.preRuleModel});

  @override
  State<AddRule> createState() => _AddRuleState();
}

class _AddRuleState extends State<AddRule> {
  final formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

@override
  void initState() {
    if(widget.preRuleModel!=null){
      titleController.text = widget.preRuleModel!.title;
      descController.text = widget.preRuleModel!.description;
    }
    // TODO: implement 

    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    bool isUpdate = (widget.preRuleModel!=null);

    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();
    MessProvider messProvider = context.watch<MessProvider>();

    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          title: Text("Add Rule", style: getTextStyleForTitleXL(),),
          backgroundColor: Colors.grey,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleController,
                        // onTapOutside: (event) {// close keyboard
                          // FocusScope.of(context).unfocus();
                        // },
                        
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        validator: (value) {
                          return titleValidator(value.toString());
                        },
                        decoration: InputDecoration(
                          label: Text("Title"),
                          border: OutlineInputBorder(
              
                          )
                        )
                        
                      ),
                    ),
              
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: descController,
                        // onTapOutside: (event) {// close keyboard
                          // FocusScope.of(context).unfocus();
                        // },
                        maxLines: 10,
                        textInputAction: TextInputAction.newline,
                        validator: (value) {
                          return descValidator(value.toString());
                        },
                        decoration: FromFieldDecoration(
                          hintText: "Write Details about",
                          label: "Description ",
                        )
                      ),
                    ),
         
                  ],
                ),
              ),
        
              SizedBox(
                height: 50,
              ),
              
              messProvider.isLoading? showCircularProgressIndicator()
              :
              getButton(
                label: isUpdate ? "Update":"Submit", 
                ontap: ()async{
                  bool valided  = formKey.currentState!.validate();
                  if(valided){
                    if(amIAdmin(messProvider: messProvider, authProvider: authProvider)||amIactmenager(messProvider: messProvider, authProvider: authProvider)){
                      // add a transaction to datebase 
                      if(isUpdate){
                        await messProvider.updateAMessRule(
                          ruleModel: RuleModel(
                            tnxId: widget.preRuleModel!.tnxId, 
                            title: titleController.text.toString(), 
                            description: descController.text.toString(),
                            createdAt: widget.preRuleModel!.createdAt,
                          ), 
                          messId: authProvider.getUserModel!.currentMessId, 
                          onFail: (message) {  
                            showSnackber(context: context, content: "Sonthing Wrong, Try Again!\n$message");
                          },
                          onSuccess: (){
                            showSnackber(context: context, content: "Updatation Successed");
                            Navigator.pop(context);
                          }
                        );
                      }
                      else{
                        await messProvider.addAMessRule(
                          ruleModel: RuleModel(
                            tnxId: DateTime.now().millisecondsSinceEpoch.toString(), 
                            title: titleController.text.toString(), 
                            description: descController.text.toString()
                          ), 
                          messId: authProvider.getUserModel!.currentMessId, 
                          onFail: (message) {  
                            showSnackber(context: context, content: "Sonthing Wrong, Try Again!\n$message");
                          },
                          onSuccess: (){
                            titleController.clear();
                            descController.clear();
                            showSnackber(context: context, content: "New Mess Rule Added Successfully");
                          }
                        );
                      }
                    }
                    else{
                      showSnackber(context: context, content: "Required Administrator Power");
                    }
                  }
                  else{
                    showSnackber(context: context, content: "please, fill add required field!");
                  }
                },
              ),
              SizedBox(
                height: 50,
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}


