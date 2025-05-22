import 'package:flutter/material.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/service_provaider.dart';
import 'package:provider/provider.dart';

class JoinOrLeave extends StatefulWidget {
  const JoinOrLeave({super.key});

  @override
  State<JoinOrLeave> createState() => _JoinOrLeaveState();
}

class _JoinOrLeaveState extends State<JoinOrLeave> {

  void _LeaveMess()async{
    final authProvaider = context.read<AuthenticationProvider>();
    final serviceProvaider = context.read<ServiceProvaider>();
    if(authProvaider.userModel!.currentMessId!=""){

      // if offline stop leave process .
      if(!serviceProvaider.isOnline) {
        showSnackber(context: context, content: "No Internet");
        serviceProvaider.setIsloading(false);
        return;
      }

      serviceProvaider.setIsloading(true);

      // remove assign mess id from user profile data.
      await Future.delayed(Duration(seconds: 2));

      await serviceProvaider.removeMessIdToMemberProfile(
        onFail: (message) 
        {  
          // on failed show a "failed message"
          serviceProvaider.setIsloading(false);
          showSnackber(context: context, content: message);
        }, 
        memberUid: authProvaider.userModel!.uId,
        onSuccess: (){
          //remove current mess id from your user id.
          // because auth provaider hold current mess id in user model. it will not replace until you relunch/login the app. 
          // clear manually
          authProvaider.userModel!.currentMessId = "";

          // on success show a "success message"
          showSnackber(context: context, content: "Leaved from the Mess");
        },
      );
      // al done. stop loading
      serviceProvaider.setIsloading(false);
    }
    else{
      showSnackber(context: context, content: "you not in any mess!");
    }

  }
  
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text("Mess Join Invitations :"),
          ...List.generate(10, (index){
            return Container(
              padding: EdgeInsets.all(10),
              height: 100,
            );
          }),
          Text("Ownership Proposal :"),
          ...List.generate(10, (index){
            return Container(
              padding: EdgeInsets.all(10),
              height: 100,
            );
          }),
          
        ],
      )
    );
  }
}