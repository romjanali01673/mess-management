import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class MealEntryScreen extends StatefulWidget {
  const MealEntryScreen({super.key});

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {

  var timeController  = TextEditingController();
  var dateController  = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    timeController.dispose();
    dateController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onTap: () async{
                      DateTime? date = await showDatePicker(
                        // fieldHintText: "mm/dd/YYYY",
                        fieldLabelText: "Enter Date (MM/DD/YYYY)", // defalut "Enter Date"
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate : DateTime(2000,12,30,12,59,59),
                        lastDate: DateTime(2050),
                        initialDatePickerMode: DatePickerMode.day,
                        initialEntryMode:DatePickerEntryMode.calendar,
                        // helpText: "Set Date", // default "Select date"
                      );
                      if(date!=null){
                        dateController.text = DateFormat("dd/MM/yyyy").format(date);
                      }
                    },
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        
                      ),
                      label: Text("Date(dd/MM/yyyy)"),
                      hintText: "Select date",
      
                    ),
                  ),
                ),
              ]
            )
          ),
          Expanded(
            child: Padding(
            padding: EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: 11+1,
                itemBuilder: (context, index){
                  // the button will be shown in last when we reach in last 
                  if(index==11){
                    return  getMenuItems(label: "submit", ontap: ()async{
                      bool submit = await showConfirmDialog(context: context, title: "Do you want to submit?");
                      if(submit ?? false){
                        // up to dateabase
                      }
                    });
                  }
                    
                  // it will be return 
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("romja kjsdfgk sklfgsldkfg sdfkgsldkfg sdkgf n ali-$index")
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            onTapOutside: (event) {// close keyboard
                              FocusScope.of(context).unfocus();
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Only allows digits // Only allows digits
                            ],
                            keyboardType: TextInputType.numberWithOptions(signed: true),
                            textInputAction: index==10? TextInputAction.done : TextInputAction.next,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder()
                              
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}