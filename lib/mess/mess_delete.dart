import 'package:flutter/material.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class MessDelete extends StatefulWidget {
  const MessDelete({super.key});

  @override
  State<MessDelete> createState() => _MessDeleteState();
}

class _MessDeleteState extends State<MessDelete> {
  @override
  Widget build(BuildContext context) {
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
          getMaterialButton(label: "Delete", 
            ontap: (){
              
            }
          )
        ],
      ),
    );
  }
}