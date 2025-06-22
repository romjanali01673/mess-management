import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/Deposit/add_deposit.dart';
import 'package:meal_hisab/deposit/history_of_deposit.dart';
import 'package:meal_hisab/deposit/my_deposit.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  int blance = 0;
  Deposit DepositItemGroup = Deposit.myDeposit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  spacing: 10,
                  children: [
                    getMenuItems(
                      label: "My Deposits",
                      icon: Icons.format_list_numbered_outlined, 
                      ontap: (){
                        DepositItemGroup = Deposit.myDeposit;
                        setState(() {
                          
                        });
                            
                      },
                      selected: DepositItemGroup == Deposit.myDeposit,
                    ),
                    getMenuItems(
                      label: "Deposit History", 
                      icon: Icons.h_mobiledata_sharp,
                      ontap: (){
                        DepositItemGroup = Deposit.historyOfDeposit;
                        setState(() {
                          
                        });
                            
                      },
                      selected: DepositItemGroup == Deposit.historyOfDeposit,
                    ),
                    getMenuItems(
                      icon: Icons.create,
                      label: "Entry", 
                      ontap: (){
                        // DepositItemGroup = Deposit.addDeposit;
                        // setState(() {
                          
                        // });
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AddDeposit())); 
                      },
                      selected: DepositItemGroup == Deposit.addDeposit,
                    ),
                  ],
                ),
              ),
            ),
            DepositItemGroup==Deposit.historyOfDeposit? DepositHistory() 
            :
            DepositItemGroup==Deposit.addDeposit? AddDeposit()
            :
            MyDeposit(),
          ],     
        ),
      ),
    );
  }
}

