import 'package:flutter/material.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
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
    
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();
    
    if(authProvider.getUserModel!.currentMessId==""){
      // because the member are not included to a mess
      return;
    }

    messProvider.setIsloading(true);
    await messProvider.getMessData(  
      onFail: (message){
        if(context.mounted){
          showSnackber(context: context, content: message);
          print(message);
        }
      }, 
      messId:authProvider.getUserModel!.currentMessId ,
    );
    messProvider.setIsloading(false);
  }

  void _deleteMess()async{
    final authProvider = context.read<AuthenticationProvider>();
    final messProvider = context.read<MessProvider>();
    if(amIAdmin(messProvider: messProvider, authProvider: authProvider)){

      // if offline stop leave process .
      if(!messProvider.isOnline) {
        showSnackber(context: context, content: "No Internet");
        messProvider.setIsloading(false);
        return;
      }

      messProvider.setIsloading(true);

      // delete mess collection/table
      await messProvider.deleteMess(
        uId: authProvider.getUserModel!.uId,
        messId: messProvider.getMessModel!.messId,
        onFail: (message) 
        {  
          // on failed show a "failed message"
          messProvider.setIsloading(false);
          showSnackber(context: context, content: "Mess Deleted Failed.\n$message");
        }, 
        onSuccess: ()async{
          showSnackber(context: context, content: "Mess Has Deleted");
          setState(() {
            
          });
        }, 
      );
      // al done. stop loading
      messProvider.setIsloading(false);
    }
    else{
      showSnackber(context: context, content: "May you don't have own Mess! \n only primary Mess owner can delete Mess!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final messProvider = context.watch<MessProvider>();

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              messProvider.isLoading?  showCircularProgressIndicator()
              :
              messProvider.getMessModel!=null?
              Card(
                color: Colors.red.shade500,
                child: ListTile(
                  title: Text(messProvider.getMessModel!.messName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Id :${messProvider.getMessModel!.messId} "),
                      Text("Address :${messProvider.getMessModel!.messAddress} "),
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
              messProvider.isLoading?
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
        ),
      ),
    );
  }
}