import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_management/bazer/bazer_entry.dart';
import 'package:mess_management/bazer/bazer_list.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/item_provider.dart';
import 'package:mess_management/home.dart';
import 'package:mess_management/helper/ui_helper.dart';

class BazerScreen extends StatefulWidget {
  const BazerScreen({super.key});

  @override
  State<BazerScreen> createState() => _BazerScreenState();
}

class _BazerScreenState extends State<BazerScreen> {
  BazerScreenMenu bazerScreenMenuGroup = BazerScreenMenu.bazerList;
  ItemProvider itemProvider = ItemProvider();
  int bazerItem =0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(5),
        // color: Colors.amber,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  getMenuItems(
                    label: "Bazer List", 
                    icon: Icons.format_list_numbered_rounded,
                    ontap: (){
                      setState(() {
                        
                      });
                      bazerScreenMenuGroup = BazerScreenMenu.bazerList;
                    },
                    selected: bazerScreenMenuGroup == BazerScreenMenu.bazerList,
                  ),
                  getMenuItems(
                    label: "Bazer Entry", 
                    icon: Icons.create,
                    ontap: (){
                      // setState(() {
                        
                      // });
                      // bazerScreenMenuGroup = BazerScreenMenu.bazerEntry;
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>BazerEntryScreen(preBazerModel: null)));
                      
                    }, 
                    selected: bazerScreenMenuGroup == BazerScreenMenu.bazerEntry,
                  ),
                  
                ],
              ),
            ),
            bazerScreenMenuGroup == BazerScreenMenu.bazerEntry ? BazerEntryScreen(preBazerModel: null,):SizedBox.shrink(),
            bazerScreenMenuGroup == BazerScreenMenu.bazerList ? BazerListScreen():SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}



