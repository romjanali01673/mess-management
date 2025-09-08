
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/deposit/add_deposit.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/deposit_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/deposit_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MemberWise extends StatefulWidget {
  const MemberWise({super.key});

  @override
  State<MemberWise> createState() => _MemberWiseState();
}

class _MemberWiseState extends State<MemberWise> {
  bool _isDisposed = false;
 
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
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            
             getHistoryMemberWise()
          ],
        ),
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

    List<Map<String,dynamic>> data = messProvider.getMessModel!.messMemberList;
    return messProvider.getMessModel!.messMemberList.isEmpty?
      Center(child: Text('No member found.'))
      :
      ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
                                  backgroundColor: memberType==Constants.member? Colors.amber :Colors.red,
                                  child: Text((index+1).toString()),
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
                                        mealSessionId: authProvider.getUserModel!.mealSessionId,
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
                              mealSessionId: authProvider.getUserModel!.mealSessionId,
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
                                                    mealSessionId: authProvider.getUserModel!.mealSessionId,
                                                    onFail: (message){
                                                      showSnackber(context: context, content: "Deletion Failed!\n$message");
                                                    },
                                                    onSuccess: (){
                                                      showSnackber(context: context, content: "Deposit Has Deleted");
                                                      setState(() {
                                                        
                                                      });
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

