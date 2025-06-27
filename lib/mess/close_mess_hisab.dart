import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/colse_mess_hisab_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class MessCloseScreen extends StatefulWidget {
  const MessCloseScreen({super.key});

  @override
  State<MessCloseScreen> createState() => _MessCloseScreenState();
}

class _MessCloseScreenState extends State<MessCloseScreen> {
  @override
  Widget build(BuildContext context) {
    final colseMessHisabProvider = context.read<ColseMessHisabProvider>();
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: Colors.green.shade100,
        child: Center(
          child: ElevatedButton(
            onPressed: ()async{
              if(amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider)){
                bool confirm = await  showConfirmDialog(context: context, title: "your mess all transactions will be removed or cleard exipt fund and mess member");
                if(confirm){
                  colseMessHisabProvider.closeMessHisab(
                    messId: authProvider.getUserModel!.currentMessId,
                    onFail: (message){
                      showSnackber(context: context, content: "Failed\n$message");
                    },
                    onSuccess: (){
                      showSnackber(context: context, content: "Successed");
                    }
                  );
                }
              }
              else{
                showSnackber(context: context, content: "required Administrator power");
              }
            }, 
            child: Text("close"),
          )
        ),
      ),
    );  }
}