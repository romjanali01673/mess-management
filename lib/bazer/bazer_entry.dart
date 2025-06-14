
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/bazer_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/bazer_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class BazerEntryScreen extends StatefulWidget {
  const BazerEntryScreen({super.key});

  @override
  State<BazerEntryScreen> createState() => _BazerEntryScreenState();
}

class _BazerEntryScreenState extends State<BazerEntryScreen> {

  TimeOfDay? time;
  DateTime? date;

  List<Map<String, dynamic>> bazerList = [];

  final dropdownKey = GlobalKey<DropdownSearchState>();

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  List<String > list =["1","2","demo"];
  // member uid|name
  Map<String,(String,String)> memberUidList={};
  String selectedItem = "Select Member";
  Set<String> disabledItems ={};

  // Future<List<String>> _getAllMemberData()async{
  //   list.clear();
  //   disabledItems.clear();
  //   final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //   final messProvaider = context.read<MessProvaider>();
    
  //   if(messProvaider.getMessModel==null) return list;
  //   for(String uid in messProvaider.getMessModel!.messMemberList){
  //     try {
  //       DocumentSnapshot documentSnapshot = await firebaseFirestore
  //         .collection(Constants.users)
  //         .doc(uid)
  //         .get();
  //       if(documentSnapshot.exists){
  //         list.add("Name: ${documentSnapshot[Constants.fname]} \nId: ${documentSnapshot[Constants.uId]}");
  //         memberUidList["Name: ${documentSnapshot[Constants.fname]} \nId: ${documentSnapshot[Constants.uId]}"] = (uid,documentSnapshot[Constants.fname]);//(uid,name)
  //         if(messProvaider.getMessModel!.disabledMemberList.contains(uid)){
  //           disabledItems.add("Name: ${documentSnapshot[Constants.fname]} \nId: ${documentSnapshot[Constants.createdAt]}");
  //         }
  //       }
  //     } catch (e) {
  //       showSnackber(context: context, content: e.toString());
  //     }
  //   }
  //   return list;
  // }


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
  void dispose() {
    dateController.dispose();
    timeController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final messProvaider = context.read<MessProvaider>();
    final authProvaider = context.read<AuthenticationProvider>();
    final bazerProvaider = context.read<BazerProvaider>();



    return Expanded(
      child: Container(
        // color: Colors.amber,
        height: double.infinity,
        width: double.infinity,
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
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onTap: () async{

                        date = await showDatePicker(
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
                          dateController.text = DateFormat("dd/MM/yyyy").format(date!);
                        }
                      },
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          
                        ),
                        label: FittedBox(child: Text("Date(dd/MM/yyyy)")),
                        hintText: "Select date",
        
                      ),
                    ),
                  ),
        
                  SizedBox(width: 10,),
        
                  Expanded(
                    child: TextField(
                      onTap: () async{
                        time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.dial,
                          helpText: "Set Time",
                        );
                        if(time!=null){
                          timeController.text = formatTimeOfDay(time!);
                        }
                      },
                      readOnly: true,
                      controller: timeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                    
                        ),
                        label: FittedBox(child: Text("Time(HH:MM A/P)")),
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
                              Text("Product", style: TextStyle(fontSize: 18),),
                              Text("Price", style: TextStyle(fontSize: 18),),
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
                              children: bazerList.asMap().entries.map((entry){
                                int index = entry.key;
                                Map value = entry.value;
                                return ListTile(
                                  contentPadding: EdgeInsets.only(left: 5),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade500,
                                    child: Text("${index}", style: TextStyle(fontSize: 20)),
                                  ),
                                  title: Text(value[Constants.product], style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(value[Constants.price], style: TextStyle(fontSize: 16),),
                                      IconButton(
                                        onPressed: ()async{
                                          await showInputDialog(product: value[Constants.product], price:value[Constants.price], index: index);
                                          setState(() {
                                          });
                                        }, 
                                        icon: Icon(Icons.edit_square,color: Colors.green,)
                                      ),
                                      IconButton(
                                        onPressed: (){
                                          setState(() {
                                            bazerList.removeAt(index);
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
                        await showInputDialog();
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
            ),

            SizedBox(
              height: 50,
            ),
          
            getButton(
              label: "save", 
              ontap: ()async{
                if(amIAdmin(messProvaider:messProvaider , authProvaider: authProvaider) || amIactmenager(messProvaider:messProvaider , authProvaider: authProvaider)){
                  if(selectedItem=="Select Member"){
                    showSnackber(context: context, content: "Member Was Not Slelcted.");
                    return;
                  }
                  if(date==null){
                    showSnackber(context: context, content: "Date Was Not Slelcted.");
                    return;
                  }
                  if(time==null){
                    showSnackber(context: context, content: "Time Was Not Slelcted.");
                    return;
                  }
                  if(bazerList.isEmpty){
                    showSnackber(context: context, content: "The list of bazer are empty");
                    return;
                  }
                  else{
                    // all valid
                    double totalAmount=0;
                    try {
                      bazerList.map((x){
                        totalAmount += double.parse(x[Constants.price]);
                      }).toList();
                    } catch (e) {
                      print(e);
                      return;
                    }
                    BazerModel  bazerModel = BazerModel(
                      transactionId: DateTime.now().millisecondsSinceEpoch.toString(), 
                      amount: totalAmount, 
                      bazerList: bazerList,
                      bazerTime: formatTimeOfDay(time!).toString(),
                      bazerDate: DateFormat("dd/MM/yyyy").format(date!).toString(),
                      byWho: {
                        Constants.uId: memberUidList[selectedItem]!.$1, 
                        Constants.fname:memberUidList[selectedItem]!.$2,
                      },
                    );
                    print(totalAmount.toString()+"a");

                    await bazerProvaider.addABazerTransaction(
                      bazerModel: bazerModel, 
                      messId: authProvaider.getUserModel!.currentMessId, 
                      onFail: (message ) { 
                        showSnackber(context: context, content: "Bazer Entry Failed!\n$message");
                      },
                      onSuccess: (){
                        showSnackber(context: context, content: "Bazer Entry Successed!");
                      }
                    );

                    // success 
                    setState(() {
                      bazerList.clear();
                    });
                  }
                }
                else{
                  showSnackber(context: context, content: "Required Menager/Act Menager power");
                }
              }
            ),
        
          ],
        ),
      ),
    );
  }

  Future<void> showInputDialog({String? product, String? price, int? index})async{
    bool isUpdate = index!=null ? true:false;
    TextEditingController productController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    productController.text = product??"";
    priceController.text = price??"";

    final formKey = GlobalKey<FormState>();
    FocusNode focusProduct = FocusNode();
    FocusNode focusPrice = FocusNode();
    
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
                controller: productController ,
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
                controller: priceController,
                autofocus: true,
                focusNode: focusPrice,
                onFieldSubmitted: (value){
                  FocusScope.of(context).unfocus();
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
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
              Navigator.pop(context, {Constants.product : product, Constants.price: price});
            }, 
            
            child:isUpdate? Text("Update") : Text("Add"),
          ),
        ],
      ),
    );
    if(map!=null){
      if(validatePrice(map[Constants.price])==null){
        isUpdate?
        bazerList[index!] = {
          Constants.price : price,
          Constants.product : product, 
        }
        : 
        bazerList.add(
          {
            Constants.product : product, 
            Constants.price : price,
          }
        );
        setState(() {
        
        });
      }
      else{
        showSnackber(context: context, content: validatePrice(map[Constants.price])!);
      }
    }
    productController.dispose();
    priceController.dispose();
  }
}