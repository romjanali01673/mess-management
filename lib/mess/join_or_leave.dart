import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/joining_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class JoinOrLeave extends StatefulWidget {
  const JoinOrLeave({super.key});

  @override
  State<JoinOrLeave> createState() => _JoinOrLeaveState();
}

class _JoinOrLeaveState extends State<JoinOrLeave> {



  Future<List<JoiningModel>> getInvaitationsList()async{
    List<JoiningModel> list=[
      JoiningModel(
        invaitationId: 'invaitation id', messName: "mess name", messId: "mess id", status: "Panding", description: "description", messAddress: "address", invaitedTime: "12:12:12 am"
      ),
    ];
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final messProvaider = context.read<MessProvaider>();
      final authProvaider = context.read<AuthenticationProvider>();
      if(authProvaider.userModel!.currentMessId=="") return;
      messProvaider.getMessData(
        onFail:(message){
          showSnackber(context: context, content: "$message");
        } , 
        messId:authProvaider.userModel!.currentMessId,
        onSuccess: (){
          debugPrint("success");
        }
      );
    });
  }

  void _LeaveMess()async{
    final authProvaider = context.read<AuthenticationProvider>();
    final messProvaider = context.read<MessProvaider>();
    if(authProvaider.userModel!.currentMessId!=""){

      // if offline stop leave process .
      if(!messProvaider.isOnline) {
        showSnackber(context: context, content: "No Internet");
        messProvaider.setIsloading(false);
        return;
      }

      messProvaider.setIsloading(true);

      // remove assign mess id from user profile data.
      await messProvaider.removeMessIdFromMemberProfile(
        onFail: (message) 
        {  
          // on failed show a "failed message"
          messProvaider.setIsloading(false);
          showSnackber(context: context, content: message);
        }, 
        memberUid: authProvaider.userModel!.uId,
        onSuccess: (){
          //remove current mess id from your user id.
          // because auth provaider hold current mess id in user model. it will not replace until you relunch/login the app. 
          // clear manually
          authProvaider.setUserModel(currentMessId: "");
          // on success show a "success message"
          showSnackber(context: context, content: "Leaved from the Mess");
        },
      );
      // al done. stop loading
      messProvaider.setIsloading(false);
    }
    else{
      showSnackber(context: context, content: "you not in any mess!");
    }

  }
  
  
  @override
  Widget build(BuildContext context) {
    final authProvaider = context.watch<AuthenticationProvider>();
    final messProvaider = context.watch<MessProvaider>();
    return Expanded(
      child: Column(
        spacing: 10,
        children: [
          Card(
            child: ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              title: Text("The Invaitations Offer Will be validate for 3 days. if you didn't accept the profosal within the spacify date you can't join later.",textAlign: TextAlign.justify,),
            ),
          ),
          
          messProvaider.isLoading? SizedBox.square(dimension: 50,child: CircularProgressIndicator(),)
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
              future:getInvaitationsList() ,
              
              builder: (context, AsyncSnapshot<List<JoiningModel>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's save 
                  return Center(child: CircularProgressIndicator());
                }
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } 
                else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No invitations found.'));
                }
                else{
                  debugPrint(snapshot.data!.length.toString());
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index){
                      JoiningModel joiningModel = snapshot.data![index];
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
                                  Text("Time: "+joiningModel.invaitedTime),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text("Status: (${joiningModel.status})"),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                icon: Icon(Icons.more_horiz),
                                itemBuilder: (context)=>[
                                  PopupMenuItem(
                                    child: Text("Join"),
                                    onTap: ()async{
                                      if(authProvaider.userModel!.currentMessId==""){
                                        bool? res = await showConfirmDialog(
                                          context: context, 
                                          title: "Do you Want to join?",
                                        ); 
                                        if(res??false){
                                          // join to the new mess
                                          if(joiningModel.status==JoiningStatus.panding){
                                            //   // you are valid join to the mess
                                            messProvaider.joiningToInvaitatedMess(
                                              messId: joiningModel.messId, 
                                              uId: authProvaider.userModel!.uId,
                                              onFail: (message){
                                                showSnackber(context: context, content: "Mess Joining Failed\n$message");
                                              }, 
                                              onSuccess: ()async{
                                                // change invaitation ststus
                                                await messProvaider.changeJoiningInvaitationStatus(
                                                  status: JoiningStatus.joined,
                                                  invaitationsId: joiningModel.invaitationId,
                                                  onFail: (message){
                                                    showSnackber(context: context, content: "somthing Wrong\n$message");
                                                  },
                                                );
                                                
                                                // update current mess id
                                                authProvaider.setUserModel(currentMessId: joiningModel.messId);
                                                messProvaider.assignMessIdToMemberProfile(
                                                  memberUid: authProvaider.userModel!.uId, 
                                                  messId: joiningModel.messId,
                                                  onFail: (message){
                                                    showSnackber(context: context, content: "somthing Wrong\n$message");
                                                  }, 
                                                );
                                                //
                                                setState(() {
                                                  // we get new data 
                                                  // by fatching new data we get new/updated status of this card.
                                                });
                                              }
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
                                        await messProvaider.changeJoiningInvaitationStatus(
                                          status: JoiningStatus.declain,
                                          invaitationsId: joiningModel.invaitationId,
                                          onFail: (message){
                                            showSnackber(context: context, content: "somthing Wrong\n$message");
                                          },
                                          onSuccess: (){
                                            showSnackber(context: context, content: "Declained");
                                          }
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
                                Text(joiningModel.description),
                                Text(joiningModel.messId),
                                Text(joiningModel.messAddress),

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


