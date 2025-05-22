import 'package:flutter/material.dart';

class Invaitations extends StatefulWidget {
  const Invaitations({super.key});

  @override
  State<Invaitations> createState() => _InvaitationsState();
}

class _InvaitationsState extends State<Invaitations> {
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