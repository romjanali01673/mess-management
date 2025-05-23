import 'package:flutter/material.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/service_provaider.dart';
import 'package:provider/provider.dart';

class MessDelete extends StatefulWidget {
  const MessDelete({super.key});

  @override
  State<MessDelete> createState() => _MessDeleteState();
}



class _MessDeleteState extends State<MessDelete> {

  void _deleteMess()async{
    final authProvaider = context.read<AuthenticationProvider>();
    final serviceProvaider = context.read<ServiceProvaider>();
    if(authProvaider.userModel!.currentMessId != "" && serviceProvaider.getMessModel != null && serviceProvaider.getMessModel!.messAuthorityId==authProvaider.userModel!.uId){

      // if offline stop leave process .
      if(!serviceProvaider.isOnline) {
        showSnackber(context: context, content: "No Internet");
        serviceProvaider.setIsloading(false);
        return;
      }

      serviceProvaider.setIsloading(true);

      // // remove assign mess id from user profile data.
      // await Future.delayed(Duration(seconds: 2));

      // delete mess collection/table
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
      showSnackber(context: context, content: "May you don't have own Mess! \n only primary Mess owner can delete Mess!");
    }
  }

  @override
  Widget build(BuildContext context) {
        final serviceProvaider = context.watch<ServiceProvaider>();

    return Container(
      child: Column(
        children: [
          Card(
            color: Colors.red.shade500,
            child: ListTile(
              title: Text("Higher Socity"),
              subtitle: Text("madhubpur, habiganj"),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          serviceProvaider.isLoading?
          SizedBox.square(
            dimension: 50,
            child: CircularProgressIndicator(),
          )
          :
          getMaterialButton(label: "Delete", 
            ontap: (){
              _deleteMess();
            }
          )
        ],
      ),
    );
  }
}