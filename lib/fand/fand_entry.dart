
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/deposit_model.dart';
import 'package:meal_hisab/model/fand_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/deposit_provider.dart';
import 'package:meal_hisab/providers/fand_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class AddFand extends StatefulWidget {
  final FandModel? preFandModel;
  const AddFand({super.key, this.preFandModel, });

  @override
  State<AddFand> createState() => _AddFandState();
}

class _AddFandState extends State<AddFand> {
  bool isUpdate = false;
  final formKey = GlobalKey<FormState>();

  FocusNode focusDiscreption = FocusNode();
  FocusNode focusAmount = FocusNode();
  FocusNode focusTitle = FocusNode();

  TextEditingController titleController = TextEditingController(); 
  TextEditingController descriptionController = TextEditingController(); 
  TextEditingController amountController = TextEditingController();
  bool isAdd = true;



  void setPreData(){
    isUpdate = true;
    titleController.text = widget.preFandModel!.title;
    descriptionController.text = widget.preFandModel!.description;
    amountController.text = widget.preFandModel!.amount.toString();
  }

  @override
  void initState() {
    if(widget.preFandModel != null){
      setPreData();
    }
    
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    final fandProvider = context.watch<FandProvider>();
    final authProvider = context.watch<AuthenticationProvider>();
    final messProvider = context.watch<MessProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Fand Entry", style: getTextStyleForTitleXL(),),
        backgroundColor: Colors.grey,
      ),
      body: Container(
        height: double.infinity,
        color: Colors.green.shade50,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Cost"),
                  Switch(
                    
                    value: isAdd, 
                    onChanged: (val){
                      if(!isUpdate){
                        setState(() {
                          isAdd = val;
                        });
                      }
                      else{
                        showSnackber(context: context, content: "For Update \"Entry Type\" Can't Be Changed");
                      }
                    },
                  ),
                  Text("Add"),
                ],
              ),

             
        
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleController,
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        focusNode: focusTitle,
                        onFieldSubmitted: (value){
                          FocusScope.of(context).requestFocus(focusDiscreption);
                        },
                        validator: (value) {
                          return titleValidator(value.toString());
                        },

                        decoration: FromFieldDecoration(
                          hintText: "Write here...",
                          label: "Title",
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: descriptionController,
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        autofocus: false,
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

                        decoration: FromFieldDecoration(
                          hintText: "Write About The Deposit",
                          label: "Discreption (Optional)",
                        )
                      ),
                    ),
                
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: amountController,
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
                label: isUpdate?"Update":"Submit", 
                ontap: ()async{
                if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider)||amIactmenager(messProvider: messProvider, authProvider: authProvider))){
                  showSnackber(context: context, content: "required Administrator power");
                  return;
                }

                  bool valided  = (formKey.currentState!.validate());
                  
                  if(valided){
                    if(isUpdate){
                      await fandProvider.updateAFandTransaction(
                        fandModel : FandModel(
                          tnxId: widget.preFandModel!.tnxId, 
                          title: titleController.text.toString(), 
                          description: descriptionController.text.toString(), 
                          amount: double.parse(amountController.text.toString()), 
                          type: widget.preFandModel!.type, 
                        ), 
                        extraAmount: double.parse(amountController.text.toString()) - widget.preFandModel!.amount ,
                        messId: authProvider.getUserModel!.currentMessId, 
                        onFail: (message ) { 
                          showSnackber(context: context, content: "Updaate Failed! \n$message");
                        },
                        onSuccess: (){ 
                          formKey.currentState!.reset();
                          showSnackber(context: context, content: "Update Success!");
                        }, 
                      );
                      // we should clear pre data other wise pre grabage data can make wrong submesion
                      isUpdate = false;
                      titleController.clear();
                      amountController.clear();
                      descriptionController.clear();

                      setState(() {
                            
                      });
                    }
                    else{
                      await fandProvider.addAFandTransaction(
                        fandModel : FandModel(
                          tnxId: DateTime.now().millisecondsSinceEpoch.toString(), 
                          title: titleController.text.toString(), 
                          description: descriptionController.text.toString(), 
                          amount: double.parse(amountController.text.toString()), 
                          type: isAdd? Constants.add : Constants.sub, 
                        ), 
                        messId: authProvider.getUserModel!.currentMessId, 
                        onFail: (message ) { 
                          showSnackber(context: context, content: "Entry Failed! \n$message");
                        },
                        onSuccess: (){ 
                          formKey.currentState!.reset();
                          showSnackber(context: context, content: "Entry Success!");
                        }, 
                      );
                      isUpdate = false;
                      titleController.clear();
                      amountController.clear();
                      descriptionController.clear();

                      setState(() {
                            
                      });
                    }
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