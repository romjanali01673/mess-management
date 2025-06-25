
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/deposit/add_deposit.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/deposit_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/deposit_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class DepositHistory extends StatefulWidget {
  const DepositHistory({super.key});

  @override
  State<DepositHistory> createState() => _DepositHistoryState();
}

class _DepositHistoryState extends State<DepositHistory> {
  bool  showTotalDepositOfMess = false;
  bool _isDisposed = false;
  HistoryOfDeposit historyOfDepositItemGroup = HistoryOfDeposit.allHostory;
  List<Map<String, List>> month = [
    
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    {"January" : [false, "January"]},
    //  "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
  ];

  @override
  void dispose() {
    // TODO: implement dispose
    _isDisposed = true;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final depositProvider = context.read<DepositProvider>();
    final messProvider = context.read<MessProvider>();

    if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
      return Center(child: Text("Required Administrator Power"),);
    }
    
    return Expanded(
      child: Column(
        children: [
            StatefulBuilder(
              builder: (context, setLocalState) {
                return Card(
                   color: Colors.green.shade500,
                   child: ListTile(
                     trailing: IconButton(
                       onPressed: (){
                         setLocalState(() {
                         showTotalDepositOfMess = !showTotalDepositOfMess;

                         });
                       }, 
                       icon: showTotalDepositOfMess? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                     ),
                     title: 
                     showTotalDepositOfMess? 
                     FutureBuilder(
                       future: depositProvider.getDepositAmount(
                         messId: authProvider.getUserModel!.currentMessId,
                         uId: authProvider.getUserModel!.uId,
                         onFail: (message){
                           showSnackber(context: context, content: "somthing Wrong! \n$message");
                         },
                       ),
                       builder: (context, AsyncSnapshot snapshot) {
                         if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                           return Center(child: showCircularProgressIndicator());
                         }
                         // else if (snapshot.hasError) {
                         //     return Center(child: Text('Error: ${snapshot.error}'));
                         // } 
                         // else if (!snapshot.hasData || snapshot.data == null) {
                         //     return Center(child: Text('No Transaction found.'));
                         // }
                         return Row(
                           children: [
                             Expanded(child: Text("Total Deposit Of Mess: ",)),
                             showPrice(value: depositProvider.getTotalDepositOfMess),
                           ],
                         );
                       }
                     )
                     :
                     Text("See Deposited Amount Of Mess"),
                   ),
                 );
              }
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  spacing: 10,
                  children: [
                    getMenuItems(
                      label: "All History", 
                      icon: FontAwesomeIcons.a,
                      ontap: (){
                        historyOfDepositItemGroup = HistoryOfDeposit.allHostory;
                        setState(() {
                          
                        });
                            
                      },
                      selected: historyOfDepositItemGroup == HistoryOfDeposit.allHostory,
                    ),
                    getMenuItems(
                      icon: Icons.group,
                      label: "Member Wise", 
                      ontap: (){
                        historyOfDepositItemGroup = HistoryOfDeposit.memberWise;
                        setState(() {
                          
                        });
                            
                      },
                      selected: historyOfDepositItemGroup == HistoryOfDeposit.memberWise,
                    ),
                  ],
                ),
              ),
            ),
            historyOfDepositItemGroup== HistoryOfDeposit.memberWise? getHistoryMemberWise()
            :
            getAllHistoryOfDeposit()
            
        ],
      ),
    );
  }


  Widget getAllHistoryOfDeposit(){
    final depositProvider  = context.read<DepositProvider>();
    final authProvider  = context.read<AuthenticationProvider>();
    return Expanded(
      child: FutureBuilder(
        future: depositProvider.getAllDepositList(
          messId: authProvider.getUserModel!.currentMessId, 
          onFail: (message ) { 
            showSnackber(context: context, content: "somthing Wrong! \n$message");
          },
        ), 
        builder: (context, AsyncSnapshot<List<Map<String,dynamic>>?> snapshot){
          if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
            return Center(child: showCircularProgressIndicator());
          }
          else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No Transaction found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index){
              DepositModel depositModel = snapshot.data![index][Constants.blance];
              Map<String,dynamic> userData = snapshot.data![index][Constants.userData];
              bool showDetails = false;
              return StatefulBuilder(
                builder:(context, setLocalState){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 10),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text("${index+1}"),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${userData[Constants.fname]}"),
                            Row(
                              children: [
                                Text("Type: ",),
                                Text("${depositModel.type}", style: TextStyle(color:depositModel.type==Constants.deposit?Colors.green:Colors.red ),),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Text("Time: ${DateFormat("hh:mm a dd-MM-yyyy").format(depositModel.CreatedAt!.toDate().toLocal())}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${depositModel.amount}", style: TextStyle(fontSize: 18),),
                            showDetails? Icon(Icons.arrow_downward_rounded):Icon(Icons.arrow_right_rounded),
                          ],
                        ),
                        onTap: () {
                          setLocalState((){
                            showDetails = !showDetails;
                          });
                        },
                      ),
                      if(showDetails) Column(
                        spacing: 5,
                        children: [
                          Text("UId: ${userData[Constants.uId]}"),
                          Text("Tnx Id: ${depositModel.tnxId}"),
                          Text("description: ${depositModel.description==""? "Empty!" : depositModel.description}" ),
                        ]
                      
                      )
                    ],
                  );
                } 
              );
            }
          );
        }
      ),
    );
  }

  Widget getHistoryMemberWise(){

    final messProvider = context.read<MessProvider>();
    final depositProvider = context.watch<DepositProvider>();
    final authProvider = context.watch<AuthenticationProvider>();

    if(!(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))){
      return  Center(child: Text("Required Administrator Power"),);
    }

    return Expanded(
      child: FutureBuilder(
        future:messProvider.getMessData(
          onFail: (message) { 
            showSnackber(context: context, content: message);
          },
          messId: authProvider.getUserModel!.currentMessId,
          isDisposed: ()=> _isDisposed,
          onSuccess: (){
            debugPrint("get mess data success");
          },
        ),
        builder:(context, AsyncSnapshot snapshot) { 
          if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's save 
            return Center(child: CircularProgressIndicator());
          }
          
          else if (messProvider.getMessModel==null ||messProvider.getMessModel!.messMemberList.isEmpty ) {
            return Center(child: Text('No member found.'));
          }
          else{
            List<Map<String,dynamic>> data = messProvider.getMessModel!.messMemberList;
            
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                bool showDetails = false;
                Map<String,dynamic> memberData = data[index];
                String memberType = 
                  messProvider.getMessModel!.menagerId==memberData[Constants.uId]? 
                    Constants.menager
                    : messProvider.getMessModel!.actMenagerId==memberData[Constants.uId]? 
                    Constants.actMenager : Constants.member;

                return StatefulBuilder(
                    builder: (context, setLocalState) { 
                    return  Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  
                                  leading: CircleAvatar(
                                    child: Text(index.toString()),
                                    backgroundColor: memberType==Constants.member? Colors.amber :Colors.red,
                                  ),
                                  title: Text(memberData[Constants.fname]),
                                  subtitle: Text("${memberData[Constants.uId]}   ($memberType)"),
                                  onTap: () {
                                    setLocalState(() {
                                      showDetails = !showDetails; 
                                    });
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FutureBuilder(
                                        future: depositProvider.getTotalDepositOfAMember(
                                          messId: authProvider.getUserModel!.currentMessId,
                                          uId: memberData[Constants.uId],
                                          onFail: (_){}
                                        ), 
                                        builder: (context , AsyncSnapshot<double> snapshot){
                                          if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                                            return Center(child: showCircularProgressIndicator());
                                          }
                                          else if (snapshot.hasError) {
                                            return Center(child: Text('Error:'));
                                          } 
                                          else if (!snapshot.hasData || snapshot.data == null) {
                                              return Center(child: Text('Error'));
                                          }
                                          return showPrice(value:snapshot.data);
                                        },
                                      ),
                                      showDetails ? Icon(Icons.arrow_downward) : Icon(Icons.arrow_forward),
                                    ],
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                          // here is the spacific member deposit transaction list 
                          if(showDetails) Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder(
                              future: depositProvider.getMemberDepositList(
                                messId: authProvider.getUserModel!.currentMessId, 
                                uId: memberData[Constants.uId],
                                onFail: (message ) { 
                                  showSnackber(context: context, content: "somthing Wrong! \n$message");
                                },
                              ), 
                              builder: (context, AsyncSnapshot<List<DepositModel>?> snapshot){
                                if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                                  return Center(child: showCircularProgressIndicator());
                                }
                                else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                } 
                                else if (!snapshot.hasData || snapshot.data == null) {
                                    return Center(child: Text('No Transaction found.'));
                                }
                                return ListView.builder(
                                  shrinkWrap: true, // ← This is the key
                                  physics: NeverScrollableScrollPhysics(),
                                  // reverse: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index){
                                    DepositModel depositModel = snapshot.data![index];
                                    bool showDetails = false;
                                    return StatefulBuilder(
                                      builder:(context, setLocalState){
                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.only(left: 10),
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.green,
                                                child: Text("${index+1}"),
                                              ),
                                              title: Row(
                                                children: [
                                                  Text("Type: ",),
                                                  Text("${depositModel.type}", style: TextStyle(color:depositModel.type==Constants.deposit?Colors.green:Colors.red ),),
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Tnx Id: ${depositModel.tnxId}"),
                                                  Text("Time: ${DateFormat("hh:mm a dd-MM-yyyy").format(depositModel.CreatedAt!.toDate().toLocal())}"),
                                                ],
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  showPrice(value: depositModel.amount),
                                                PopupMenuButton(
                                          icon: Icon(Icons.more_vert),
                                          itemBuilder: (context) =>[
                                            PopupMenuItem(
                                              value: 0,
                                              child: ListTile(
                                                title: Text("Edit"),
                                                leading: Icon(Icons.edit),
                                              ), 
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddDeposit(preDepositModel: depositModel, preMemberData: memberData,)));
                                              },
                                            ),
                                  
                                            PopupMenuItem(
                                              value: 1,
                                              // onTap: (){
                                              //   // if i use this function. we don't need to Navigator.pop()
                                              // },
                                              child: ListTile(
                                                title: Text("Delete"),
                                                leading: Icon(Icons.delete),
                                                onTap: ()async{
                                                  Navigator.pop(context); // if i use this function. we have to Navigator.pop() for close listview and can't called parent/PopupMenuItem's ontap function
                                                  bool? confirm = await showDialog(context: context, builder: (content)=>AlertDialog(
                                                    title: Text("Do you want to delete?"),
                                                    actionsAlignment: MainAxisAlignment.start,
                                                    actions: [
                                                      TextButton(child: Text("No"), onPressed: (){
                                                        Navigator.pop(context, false);
                                                      },),
                                                      TextButton(child: Text("Yes") , onPressed: (){
                                                      Navigator.pop(context, true);
                                                      },),
                                                    ],
                                                  ));
                                                  if(confirm!=null && confirm){
                                                    await depositProvider.deleteADepositTransaction(
                                                      depositModel: depositModel, 
                                                      uId: memberData[Constants.uId], 
                                                      messId: authProvider.getUserModel!.currentMessId, 
                                                      onFail: (message){
                                                        showSnackber(context: context, content: "Deletion Failed!\n$message");
                                                      },
                                                      onSuccess: (){
                                                        showSnackber(context: context, content: "Deposit Has Deleted");
                                                      }
                                                    );
                                                  }
                                                },
                                              ), 
                                            ),
                                          ]
                                        ),
                                                  // showDetails? Icon(Icons.arrow_downward_rounded):Icon(Icons.arrow_right_rounded),
                                                ],
                                              ),
                                              onTap: () {
                                                setLocalState((){
                                                  showDetails = !showDetails;
                                                });
                                              },
                                            ),
                                            if(showDetails)...[
                                              // show description here 
                                              Text(depositModel.description==""? "Description are Empty!" : depositModel.description),
                                            ]
                                          ],
                                        );
                                      } 
                                    );
                                  }
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        } 
      ),
    );
  
  }


}