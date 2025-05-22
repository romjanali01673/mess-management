import 'package:flutter/material.dart';
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// header menu items
Widget getMenuItems({required String label, required Function() ontap, IconData ? icon, selected = false}){
  return Container(
    margin: EdgeInsets.all(2),
    child: MaterialButton(
      onPressed: ontap,
      padding: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label", style: TextStyle(fontSize: 20),),
          if (icon != null) ...[ // here by the there dot we make it list of Widget, default it just was a list
              SizedBox(
                width: 10,
              ),
              Icon(icon),
            ],
          selected ? Icon(Icons.done, color: Colors.red, size: 20) : SizedBox.shrink(),
        ],
      ),
    ),
  );
}

Widget getMaterialButton({required String label, required Function() ontap, IconData ? icon, selected = false}){
  return Container(
    margin: EdgeInsets.all(2),
    child: MaterialButton(
      onPressed: ontap,
      padding: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label", style: TextStyle(fontSize: 20),),
          if (icon != null) ...[ // here by the there dot we make it list of Widget, default it just was a list
              SizedBox(
                width: 10,
              ),
              Icon(icon),
            ],
          selected ? Icon(Icons.done, color: Colors.red, size: 20) : SizedBox.shrink(),
        ],
      ),
    ),
  );
}

void showSnackber({required BuildContext context, required String content}){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}


  InputDecoration FromFieldDecoration({required dynamic label, String? hintText, Icon? prefixIcon}){
    return InputDecoration(
      label: Text("$label"),
      hintText: hintText??"",
      border: OutlineInputBorder(),
      prefix: prefixIcon?? SizedBox.shrink(),
    );
  }

  Future<bool> showConfirmDialog({required BuildContext context, required String title}) async{
    bool? res =  await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context, false);
          },
          child:Text("No"),
        ),
        TextButton(
          onPressed: (){
            Navigator.pop(context, true);
          },
          child:Text("Yes"),
        ),
      ],
    ));
    return res?? false;
  }

  void showMessageDialog({required BuildContext context, required String title, required String Discreption}){
    showDialog(context: context, builder:(context)=>AlertDialog(
      title: Text(title),
      content: Text(Discreption),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.of(context).pop();
          }, 
          child: Text("Ok"), 
        )
      ],
    ));
  }


Widget getButton({required String label, required Function() ontap, Icon? icon}){
  return MaterialButton(
    onPressed: ontap,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    height: 50,
    color: Colors.grey,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label", style: TextStyle(fontSize: 25),),
        if (icon != null) ...[
          SizedBox(
            width: 10,
          ),
          icon,
         ],
      ],
    ),);
}
   