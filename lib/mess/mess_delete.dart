import 'package:flutter/material.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:meal_hisab/provaiders/mess_provaider.dart';
import 'package:provider/provider.dart';

class MessDelete extends StatefulWidget {
  const MessDelete({super.key});

  @override
  State<MessDelete> createState() => _MessDeleteState();
}



class _MessDeleteState extends State<MessDelete> {

  @override
  void initState() {
    super.initState();  
    WidgetsBinding.instance.addPostFrameCallback((_){
      getMessData();
    });
  }

  void getMessData()async{
    
    final messProvaider = context.read<MessProvaider>();
    final authProvaider = context.read<AuthenticationProvider>();
    
    if(authProvaider.getUserModel!.currentMessId==""){
      // because the member are not included to a mess
      return;
    }

    messProvaider.setIsloading(true);
    await messProvaider.getMessData(  
      onFail: (message){
        if(context.mounted){
          showSnackber(context: context, content: message);
          print(message);
        }
      }, 
      messId:authProvaider.getUserModel!.currentMessId ,
    );
    messProvaider.setIsloading(false);
  }

  void _deleteMess()async{
    final authProvaider = context.read<AuthenticationProvider>();
    final messProvaider = context.read<MessProvaider>();
    if(authProvaider.getUserModel!.currentMessId != "" && messProvaider.getMessModel != null && messProvaider.getMessModel!.messAuthorityId==authProvaider.getUserModel!.uId){

      // if offline stop leave process .
      if(!messProvaider.isOnline) {
        showSnackber(context: context, content: "No Internet");
        messProvaider.setIsloading(false);
        return;
      }

      messProvaider.setIsloading(true);

      // delete mess collection/table
      await messProvaider.deleteMess(
        onFail: (message) 
        {  
          // on failed show a "failed message"
          messProvaider.setIsloading(false);
          showSnackber(context: context, content: message);
        }, 
        MessId: messProvaider.getMessModel!.messId,
        onSuccess: ()async{
          //remove current mess id from your user id.
          // because auth provaider hold current mess id in user model. it will not replace until you relunch/login the app. 
          // clear manually
          authProvaider.setUserModel(currentMessId: "");
          await messProvaider.removeMessIdFromMemberProfile(
            memberUid: authProvaider.getUserModel!.uId, 
            onFail: (p0) {
              showSnackber(context: context, content: "somthing wrong!");
            },
          );

          // on success show a "success message"
          showSnackber(context: context, content: "Mess Has Deleted");
          setState(() {
            
          });
        },
      );
      // al done. stop loading
      messProvaider.setIsloading(false);
    }
    else{
      showSnackber(context: context, content: "May you don't have own Mess! \n only primary Mess owner can delete Mess!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final messProvaider = context.watch<MessProvaider>();

    return Container(
      child: Column(
        children: [
          messProvaider.isLoading?  showCircularProgressIndicator()
          :
          messProvaider.getMessModel!=null?
          Card(
            color: Colors.red.shade500,
            child: ListTile(
              title: Text(messProvaider.getMessModel!.messName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Id :${messProvaider.getMessModel!.messId} "),
                  Text("Address :${messProvaider.getMessModel!.messAddress} "),
                ],
              ),
            )
          )
          :
          SizedBox(
            child: Text("No Mess Found!", style: TextStyle(color: Colors.red),),
          ),
          SizedBox(
            height: 100,
          ),
          messProvaider.isLoading?
          SizedBox.square(
            dimension: 50,
            child: CircularProgressIndicator(),
          )
          :
          getMaterialButton(
            context: context,
            label: "Delete", 
            ontap: ()async{
              bool? res = await showConfirmDialog(context: context, title: "Do You Want to Delete This Mess");
              if(res??false){
                _deleteMess();
              }
            }
          )
        ],
      ),
    );
  }
}