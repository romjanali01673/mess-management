
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/bazer_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/bazer_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class BazerEntryScreen extends StatefulWidget {
  final BazerModel? preBazerModel;
  const BazerEntryScreen({super.key,required this.preBazerModel});

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

  List<String > list =[];

  // "name" + "\n" + "uid"
  String selectedItem = "Select Member";
  Set<String> disabledItems ={};



  void setPreData(){
    if((widget.preBazerModel==null)) return;
    bazerList = (widget.preBazerModel!.bazerList as List<dynamic>).map((x)=> Map<String, dynamic> .from(x as Map)).toList();
    
    DateTime dateTime = DateFormat("h:mm a").parse(widget.preBazerModel!.bazerTime);
    time = TimeOfDay.fromDateTime(dateTime);
    timeController.text = widget.preBazerModel!.bazerTime;

    date = DateFormat("dd/MM/yyyy").parse(widget.preBazerModel!.bazerDate);
    dateController.text = widget.preBazerModel!.bazerDate;

    selectedItem = widget.preBazerModel!.byWho[Constants.fname].toString()+"\n"+widget.preBazerModel!.byWho[Constants.uId].toString();

    setState(() {
      
    });
  }


  Future<List<String>> _getAllMemberData()async{
    list.clear();
    disabledItems.clear();
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    await messProvider.getMessData(
      onFail: (message){

      }, 
      messId:authProvider.getUserModel!.currentMessId,
    );

    if(messProvider.getMessModel==null) return list;
    for(dynamic member in messProvider.getMessModel!.messMemberList){
      try {
        
          list.add("${member[Constants.fname]}\n${member[Constants.uId]}");
          if(member[Constants.status]==Constants.disable){
            disabledItems.add("${member[Constants.fname]}\n${member[Constants.uId]}");
          }
        
      } catch (e) {
        showSnackber(context: context, content: e.toString());
      }
    }
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setPreData();
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();

    super.dispose();

  }


  @override
  Widget build(BuildContext context) {
    bool isUpdate = (widget.preBazerModel!=null);

    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    final bazerProvider = context.read<BazerProvider>();



    return Scaffold(
      appBar: AppBar(),
      body: Container(
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
              label:  isUpdate?"update" : "save", 
              ontap: ()async{
                if(amIAdmin(messProvider:messProvider , authProvider: authProvider) || amIactmenager(messProvider:messProvider , authProvider: authProvider)){
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
                    BazerModel  bazerModel = isUpdate?
                    BazerModel(
                      transactionId: widget.preBazerModel!.transactionId, 
                      amount: totalAmount, 
                      bazerList: bazerList,
                      bazerTime: formatTimeOfDay(time!).toString(),
                      bazerDate: DateFormat("dd/MM/yyyy").format(date!).toString(),
                      byWho: {
                        Constants.fname:selectedItem.split('\n')[0],
                        Constants.uId: selectedItem.split('\n')[1], 
                      },
                    )
                    :
                    BazerModel(
                      transactionId: DateTime.now().millisecondsSinceEpoch.toString(), 
                      amount: totalAmount, 
                      bazerList: bazerList,
                      bazerTime: formatTimeOfDay(time!).toString(),
                      bazerDate: DateFormat("dd/MM/yyyy").format(date!).toString(),
                      byWho: {
                        Constants.fname:selectedItem.split('\n')[0],
                        Constants.uId: selectedItem.split('\n')[1], 
                      },
                    );
                    print(totalAmount.toString()+"a");

                    isUpdate?
                    await bazerProvider.updateABazerTransaction(
                      bazerModel: bazerModel, 
                      messId: authProvider.getUserModel!.currentMessId, 
                      onFail: (message ) { 
                        showSnackber(context: context, content: "Bazer Entry Failed!\n$message");
                      },
                      onSuccess: (){
                        showSnackber(context: context, content: "Bazer Entry Successed!");
                      }, 
                      extraAdd: (bazerModel.amount - widget.preBazerModel!.amount) ,
                    )

                    :
                    await bazerProvider.addABazerTransaction(
                      bazerModel: bazerModel, 
                      messId: authProvider.getUserModel!.currentMessId, 
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

  Future<void> showInputDialog({String product="", String price="", int? index})async{
    bool isUpdate = index!=null ? true:false;


    final formKey = GlobalKey<FormState>();
    FocusNode focusProduct = FocusNode();
    FocusNode focusPrice = FocusNode();
    
    Map<String,dynamic>? map = await showDialog(
      context: context, 
      builder: (context) { 
        TextEditingController productController = TextEditingController();
        TextEditingController priceController = TextEditingController();

        productController.text = product;
        priceController.text = price;
        
        return AlertDialog(
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
                    return "Empty Field!";
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
                      return "Invalid Argument";
                    }
                  return validatePrice(value.toString());
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
              if(formKey.currentState!.validate()){
                Navigator.pop(context, {Constants.product : product, Constants.price: price});
              }
            }, 
            
            child:isUpdate? Text("Update") : Text("Add"),

          ),
        ],
      );
      }
    );
    print(map);
    if(map!=null){
      
        isUpdate?
        bazerList[index] = {
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
  }
}