import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/fund_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:provider/provider.dart';

class ClearFund extends StatefulWidget {
  const ClearFund({super.key});

  @override
  State<ClearFund> createState() => _ClearFundState();
}

class _ClearFundState extends State<ClearFund> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    

  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey, // Matches your AppBar
      statusBarIconBrightness: Brightness.light, // Use Brightness.light if AppBar is dark
    ));

    FundProvider fundProvider = context.watch<FundProvider>();
    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();
    MessProvider messProvider = context.read<MessProvider>();
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Clear Fund"),
      //   backgroundColor: Colors.grey,
      // ),
    body:  Container(
      width: double.infinity,
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height:Platform.isIOS? 40:10,
          ),
          ElevatedButton(
            onPressed: ()async{
            if(!amIAdmin(messProvider: messProvider, authProvider: authProvider)){
              showSnackber(context: context, content: "Required Administator Power");
              return;
            }
            bool res = await showConfirmDialog(context: context, title: "Clear Fund Hostory", subTitle: "if you cleard fund transaction you can't be availabe next to undone. your fund blance will exist same but all fund transactions will be replaced by one net amout transaction what is current blance.");
            if(res){
              fundProvider.clearAllFundTnx(
                messId: authProvider.getUserModel!.currentMessId, 
                onFail: (message){
                  showSnackber(context: context, content: "Failed!\n$message");
                }, 
                onSuccess: (){
                  showSnackber(context: context, content: "Successed.");
                }
              );
            }
          },
          child: fundProvider.isLoading?showCircularProgressIndicator() : Text("Clear All Transactions."),
          )
        ],
      ),
    )
    );
  }
}