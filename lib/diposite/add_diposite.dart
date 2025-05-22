import 'package:flutter/material.dart';
import 'package:meal_hisab/home.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class AddDiposite extends StatefulWidget {
  const AddDiposite({super.key});

  @override
  State<AddDiposite> createState() => _AddDipositeState();
}

class _AddDipositeState extends State<AddDiposite> {
  final formKey = GlobalKey<FormState>();

  FocusNode focusDiscreption = FocusNode();
  FocusNode focusAmount = FocusNode();

  String discreption = ""; 
  String amount = ""; 


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.green.shade50,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    autofocus: true,
                    focusNode: focusDiscreption,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).requestFocus(focusAmount);
                    },
                    validator: (value) {
                      if(value.toString().trim()==""){
                        return "";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      amount = value.trim();
                    },
                    decoration: FromFieldDecoration(
                      hintText: "Write About The Diposite",
                      label: "Discreption",
                    )
                  ),
                ),
            
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    focusNode: focusAmount,
                    onFieldSubmitted: (value){
                      FocusScope.of(context).unfocus();
                    },
                    validator: (value) {
                      if(value.toString().trim()==""){
                        return "";
                      }
                      return null;
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
            
                SizedBox(
                  height: 50,
                ),
            
                getButton(
                  label: "Submit", 
                  ontap: (){
                    bool valided  = formKey.currentState!.validate();
                    if(valided){
                      setState(() {
                            
                      });
                    }
                  },
                ),
            
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}