
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';

class BazerEntryScreen extends StatefulWidget {
  const BazerEntryScreen({super.key});

  @override
  State<BazerEntryScreen> createState() => _BazerEntryScreenState();
}

class _BazerEntryScreenState extends State<BazerEntryScreen> {
  final formKey = GlobalKey<FormState>();

  FocusNode focusProduct = FocusNode();
  FocusNode focusPrice = FocusNode();


  List<Map<String, dynamic>> row = [

    {
      "${BazerEntry.description}" : "fish",
      "${BazerEntry.price}" : "200"
    },

    {
      "${BazerEntry.description}" : "fish",
      "${BazerEntry.price}" : "200"
    },

    {
      "${BazerEntry.description}" : "fish",
      "${BazerEntry.price}" : "200"
    },

  ];

  final dropdownKey = GlobalKey<DropdownSearchState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  List<String> items = ["romjan", "siam", "sayed"];
  String selectedItem = "Select Member";
  Set<String> disabledItems ={"sayed"};

  String dropDownValue = "Select Person";
  List <DropdownMenuItem> list = [
    DropdownMenuItem(
      value: "Select Person", 
      child: Text("Select Person"),
    ),
    DropdownMenuItem(
      value: "nazmul", 
      child: Text("nazmul"),
    ),
    DropdownMenuItem(
      value: "farhan", 
      child: Text("farhan"),
    ),
    DropdownMenuItem(
      value: "kapil", 
      child: Text("kapil"),
    ),
    DropdownMenuItem(
      value: "adil", 
      child: Text("adil"),
    ),
    DropdownMenuItem(
      value: 'raihan', 
      child: Text("raihan"),
    ),
    DropdownMenuItem(
      value: "al amin", 
      child: Text("al amin"),
    ),
    DropdownMenuItem(
      value: "saydur", 
      child: Text("saydur"),
    ),
    DropdownMenuItem(
      value: "sabbir", 
      child: Text("sabbir"),
    ),
    DropdownMenuItem(
      value: "saidul", 
      child: Text("saidul"),
    ),
    DropdownMenuItem(
      value: "siam", 
      child: Text("siam"),
    ),
  ];
  List<Text> t = [
    Text(" "),
    Text(" "),
    Text(" "),
    Text(" fgfds"),
  ];


  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // color: Colors.amber,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Container(
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
                      const SnackBar(content: Text("This item is disabled.")),
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
            ),
            
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
        
                  SizedBox(width: 10,),
        
                  Expanded(
                    child: TextField(
                      onTap: () async{
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.dial,
                          helpText: "Set Time",
                        );
                        if(time!=null){
                          timeController.text = formatTimeOfDay(time);
                        }
                      },
                      readOnly: true,
                      controller: timeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                    
                        ),
                        label: Text("Time(HH:MM AM)"),
                        hintText: "Select Time",
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20, top: 10),
                    height: 1000,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey.shade300,
                      border: Border(
                        
                      )
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SL NO", style: TextStyle(fontSize: 18),),
                              Text("Description", style: TextStyle(fontSize: 18),),
                              Text("Cost TK", style: TextStyle(fontSize: 18),),
                            ],
                          ),
                        ),
                    
                        Divider(
                          
                        ),
                    
                        // list of product is here.
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              // "row.asMap" make it a map where key is index and value is the map
                              // "entries" store list of pair<key, value>
                              // "entries.map((entry){})" entry is a pair
                              children: row.asMap().entries.map((entry){
                                int index = entry.key;
                                Map value = entry.value;
                                return ListTile(
                                  contentPadding: EdgeInsets.only(left: 5),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade500,
                                    child: Text("${index}", style: TextStyle(fontSize: 20)),
                                  ),
                                  title: Text(value["${BazerEntry.description}"], style: TextStyle(fontSize: 16)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(value["${BazerEntry.price}"], style: TextStyle(fontSize: 16),),
                                      IconButton(
                                        onPressed: (){
                                          row.removeAt(index);
                                          setState(() {
                                            
                                          });
                                        }, 
                                        icon: Icon(Icons.disabled_by_default_rounded,color: Colors.red.shade800,)
                                      ),
                                    ],
                                  ),
                                );
                                // return Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                                //   children: [
                                //       Text("$index", style: TextStyle(fontSize: 16),),
                                //       Text("${value["${BazerEntry.description}"]}",style: TextStyle(fontSize: 16),),
                                //       Text("${value["${BazerEntry.price}"]}",style: TextStyle(fontSize: 16),),
                                //     ],
                                // );
                              }).toList(),
                              
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 1/2,
                    right: 1/2,
              
                    child: GestureDetector(
                      onTap: () async{
                        String product = "";
                        String price = "";
                        Map<String,dynamic>? map = await showDialog(
                          context: context, 
                          builder: (context) =>AlertDialog(
                            title: Text("Add Product-"),
                            scrollable: true,
                            content: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    textInputAction: TextInputAction.next,
                                    autofocus: true,
                                    focusNode: focusProduct,
                                    onFieldSubmitted: (value){
                                      FocusScope.of(context).requestFocus(focusPrice);
                                    },
                                    validator: (value) {
                                      if(value.toString().trim()==""){
                                        return "";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      product = value.trim();
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        
                                      ),
                                      label: Text("Product Name-")
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    autofocus: true,
                                    focusNode: focusPrice,
                                    onFieldSubmitted: (value){
                                      FocusScope.of(context).unfocus();
                                    },
                                    textInputAction: TextInputAction.done,
                                    validator: (value) {
                                      if(value.toString().trim()==""){
                                        return "";
                                      }
                                      int pr =0;
                                        try{
                                          pr = int.parse(value.toString().trim());
                                          print(pr);
                                        }catch (e){
                                          return "enter int value";
                                        }
                                      return null;
                                    },
                                    onChanged: (value){
                                      price = value.trim();
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        
                                      ),
                                      label: Text("Product Price-")
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                }, 
                                child: Text("Cancle"),
                              ),
                              TextButton(
                                onPressed: (){
                                  Navigator.pop(context, {"${BazerEntry.description}" : "A", "${BazerEntry.price}": "B"});
                                }, 
                                child: Text("Add"),
                              ),
                            ],
                          ),
                        );
                        if(map!=null){
                          bool valided  = formKey.currentState!.validate();
                          if(valided){
                            add_in_bazer_List(
                              row, 
                              {
                                "${BazerEntry.description}" : product, 
                                "${BazerEntry.price}" : price,
                              },
                            );
                            setState(() {
                            
                            });
                          }
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade700,
                        child: Icon(Icons.add,color: Colors.blue,),
                      ),
                    )
                  ),                  
                ],
              ),
            )
          
        
          ],
        ),
      ),
    );
  }
}