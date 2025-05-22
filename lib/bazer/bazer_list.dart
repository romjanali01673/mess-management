import 'package:flutter/material.dart';

class BazerListScreen extends StatefulWidget {
  const BazerListScreen({super.key});

  @override
  State<BazerListScreen> createState() => _BazerListScreenState();
}

class _BazerListScreenState extends State<BazerListScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
         child: Container(
          child: ListView.builder(itemBuilder: (context , index){
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text("$index"),
              ),
              title: Text("Md Romjan Ali"),
              subtitle: Text("${DateTime.now()}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("121212", style: TextStyle(fontSize: 18),),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (context) =>[
                      
                      PopupMenuItem(
                        value: 0,
                        child: ListTile(
                          title: Text("Edit"),
                          leading: Icon(Icons.edit),
                          ), 
                      ),

                      PopupMenuItem(
                        value: 1,
                        // onTap: (){
                        //   // if i use this function. we don't need to Navigator.pop()
                        // },
                        child: ListTile(
                          title: Text("Delete"),
                          leading: Icon(Icons.delete),
                          onTap: ()async{
                            Navigator.pop(context); // if i use this function. we have to Navigator.pop() for close listview and can't called parent/PopupMenuItem's ontap function
                            bool? confirm = await showDialog(context: context, builder: (content)=>AlertDialog(
                              title: Text("Do you want to delete?"),
                              actionsAlignment: MainAxisAlignment.start,
                              actions: [
                                TextButton(child: Text("No"), onPressed: (){
                                  Navigator.pop(context, false);
                                },),
                                TextButton(child: Text("Yes") , onPressed: (){
                                  Navigator.pop(context, true);
                                },),
                              ],
                            ));
                            if(confirm!=null && confirm){
                              debugPrint("Confirmed ------------");
                            }
                            else{
                              debugPrint("Confirmed false ------------");
                            }
                          },
                        ), 
                      ),

                    ])
                ],
              ),
              onTap: (){
                // show details here 
                debugPrint("show Details Here");
              },
            );
          },
          itemCount: 50,
        ),
      ),
    );
  }
}