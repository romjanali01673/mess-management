import 'package:flutter/material.dart';

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

Widget getMaterialButton({required BuildContext context, required String label, required Function() ontap, IconData ? icon, selected = false}){
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

  if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
  else debugPrint("Snack message : "+content);
}


  InputDecoration FromFieldDecoration({required dynamic label, String? hintText, Icon? prefixIcon}){
    return InputDecoration(
      label: Text("$label"),
      hintText: hintText??"",
      border: OutlineInputBorder(),
      prefix: prefixIcon?? SizedBox.shrink(),
    );
  }

  Future<bool> showConfirmDialog({required BuildContext context, required String title, String subTitle=""}) async{
    bool? res =  await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(title,style : getTextStyleForTitleL()),
      content: Text(subTitle,style : getTextStyleForSubTitleL()),
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

Widget showCircularProgressIndicator(){
  return Center(
    child: SizedBox.square(
      dimension: 50,
      child: CircularProgressIndicator(),
    ),
  );
}
   
Widget showPrice({required dynamic value , int maxWidth = 100}) {
  double? number;

  try {
    number = double.parse(value.toString());
  } catch (_) {
    return const Text("Invalid", style: TextStyle(fontSize: 18));
  }

  // Check if the value is whole number (e.g., 123.00)
  bool isWhole = number == number.toInt();

  return Container(
    constraints: BoxConstraints(
      maxWidth: maxWidth.toDouble(),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        isWhole ? number.toInt().toString() : number.toStringAsFixed(2),
        style: const TextStyle(fontSize: 18),
      ),
    ),
  );
}

String getFormatedPrice({required dynamic value}) {
  double? number;
  
  try {
    number = double.parse(value.toString());
  } catch (_) {
    return "Invalid";
  }

  bool isWhole = number == number.toInt();
  return isWhole ? number.toInt().toString() : number.toStringAsFixed(2);
}

TextStyle getTextStyleForTitleS(){
  return TextStyle(fontSize: 16);
}
TextStyle getTextStyleForTitleM(){
  return TextStyle(fontSize: 18);
}
TextStyle getTextStyleForTitleL(){
  return TextStyle(fontSize: 20);
}
TextStyle getTextStyleForTitleXL(){
  return TextStyle(fontSize: 24);
}

TextStyle getTextStyleForSubTitleM(){
  return TextStyle(fontSize: 14);
}
TextStyle getTextStyleForSubTitleL(){
  return TextStyle(fontSize: 16);
}
TextStyle getTextStyleForSubTitleXL(){
  return TextStyle(fontSize: 18);
}