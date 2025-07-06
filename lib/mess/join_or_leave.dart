import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/joining_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class JoinOrLeave extends StatefulWidget {
  const JoinOrLeave({super.key});

  @override
  State<JoinOrLeave> createState() => _JoinOrLeaveState();
}

class _JoinOrLeaveState extends State<JoinOrLeave> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final messProvider = context.read<MessProvider>();
      final authProvider = context.read<AuthenticationProvider>();
      if(authProvider.getUserModel!.currentMessId=="") return;
      messProvider.getMessData(
        onFail:(message){
          showSnackber(context: context, content: "$message");
        } , 
        messId:authProvider.getUserModel!.currentMessId,
        onSuccess: (){
          debugPrint("success");
        }
      );
    });
  }

  void _LeaveMess()async{
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    if(authProvider.getUserModel!.currentMessId!=""){

      if(amIAdmin(messProvider: messProvider, authProvider: authProvider)){
        showSnackber(context: context, content: "At first you have to either delete the mess or transfer ownership!");
        return;
      }

      // if offline stop leave process .
      if(!messProvider.isOnline) {
        showSnackber(context: context, content: "No Internet");
        messProvider.setIsloading(false);
        return;
      }

      messProvider.setIsloading(true);

      // remove assign mess id from user profile data.
      await messProvider.leaveFromMess(
        onFail: (message) 
        {  
          // on failed show a "failed message"
          messProvider.setIsloading(false);
          showSnackber(context: context, content: message);
        }, 
        memberUid: authProvider.getUserModel!.uId,
        messId: authProvider.getUserModel!.currentMessId,
        onSuccess: (){
          //remove current mess id from your user id.
          // because auth provider hold current mess id in user model. it will not replace until you relunch/login the app. 
          // clear manually
          authProvider.setUserModel(currentMessId: "");
          // on success show a "success message"
          showSnackber(context: context, content: "Leaved from the Mess");
        },
      );
      // al done. stop loading
      messProvider.setIsloading(false);
    }
    else{
      showSnackber(context: context, content: "you not in any mess!");
    }

  }
  
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final messProvider = context.watch<MessProvider>();
    return Expanded(
      child: Column(
        spacing: 10,
        children: [
          
          messProvider.isLoading? SizedBox.square(dimension: 50,child: CircularProgressIndicator(),)
          :
          getMaterialButton(icon: Icons.run_circle ,context: context, label: "Leave Current Mess", ontap: ()async{
            bool? res = await showConfirmDialog(context: context, title: "Do you Want to leave your Current mess");
            if(res??false){
              _LeaveMess();
            }
          }),
          
          Text("Mess Joining Invitations :"),
          
          Expanded(
            child: FutureBuilder(
              future:messProvider.getInvaitationsList(uId: authProvider.getUid!, onFail: (message) {showSnackber(context: context, content: "invaitations list found Error!\n$message");}) ,
              
              builder: (context, AsyncSnapshot<List<JoiningModel?>?> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                  return Center(child: CircularProgressIndicator());
                }
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } 
                else if (!snapshot.hasData || snapshot.data == null ||snapshot.data!.isEmpty) {
                  return Center(child: Text('No invitations found.'));
                }
                else{
                  debugPrint(snapshot.data!.length.toString());
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index){
                      if(snapshot.data![index]==null) return SizedBox.shrink();
                      JoiningModel joiningModel = snapshot.data![index]!;
                      print(joiningModel.messAddress);
                    
                      return Card(
                        color: Colors.green.shade100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text(joiningModel.messName),
                              subtitle: Row(
                                children: [
                                  Expanded(child: Text("Time: "+ DateFormat("yyyy-MM-dd hh:mm a").format(joiningModel.invaitedTime!.toDate().toLocal()))),
                                 SizedBox(width: 20,),
                                  Text("Status: (${joiningModel.status})", textAlign: TextAlign.end,),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                icon: Icon(Icons.more_horiz),
                                itemBuilder: (context)=>[
                                  PopupMenuItem(
                                    child: Text("Join"),
                                    onTap: ()async{
                                      if(authProvider.getUserModel!.currentMessId==""){
                                        bool? res = await showConfirmDialog(
                                          context: context, 
                                          title: "Do you Want to join?",
                                        ); 
                                        if(res??false){
                                          // join to the new mess
                                          if(joiningModel.status==JoiningStatus.panding){
                                            //   // you are valid join to the mess
                                            messProvider.joiningToInvaitatedMess(
                                              messId: joiningModel.messId, 
                                              member: {
                                                Constants.uId:authProvider.getUserModel!.uId,
                                                Constants.fname:authProvider.getUserModel!.fname,
                                                Constants.status:Constants.enable,
                                                },
                                              invaitationsId: joiningModel.invaitationId, 
                                              status:JoiningStatus.joined,
                                              onFail: (message){
                                                showSnackber(context: context, content: "Mess Joining Failed\n$message");
                                              }, 
                                              onSuccess: ()async{
                                                showSnackber(context: context, content: "Welcome. \nYou have joinded to the mess");
                                                await authProvider.getUserProfileData(onFail: (_){});
                                                Navigator.pop(context);
                                              }, 
                                            );  
                                          }
                                          else
                                          {
                                            // the invaitations no longer valid.
                                            showSnackber(context: context, content: "You Can't Join because Mess Status: ${joiningModel.status}");
                                          }
                                        }
                                      }
                                      else{
                                        showSnackber(context: context, content: "to join another mess at first you have to leave current mess.");
                                      }
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Text("Declain"),
                                    onTap: ()async{
                                      // change invaitation ststus
                                      bool? res = await showConfirmDialog(context: context, title: "Do you want to declain this invaitations.");
                                      if(res??false){
                                        await messProvider.changeJoiningInvaitationStatus(
                                          status: JoiningStatus.declain,
                                          invaitationsId: joiningModel.invaitationId,
                                          onFail: (message){
                                            showSnackber(context: context, content: "somthing Wrong\n$message");
                                          },
                                          onSuccess: (){
                                            showSnackber(context: context, content: "Declained");
                                          }, 
                                          uId: authProvider.getUserModel!.uId,
                                        );
                                      }
                                    },
                                  ),
                                ]
                              ),
                              
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Message: "+joiningModel.description),
                                Text("Mess Id: "+joiningModel.messId),
                                Text("Mess Address: "+joiningModel.messAddress),

                              ],
                            )
                          ],
                        ),
                        
                      );
                    },
                  );
                }
                
              },
            ),
          ),
        ],
      ),
    );
  }
}


