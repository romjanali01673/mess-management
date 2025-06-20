import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meal_hisab/add_notice.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/notice_model.dart';
import 'package:meal_hisab/providers/authantication_provider.dart';
import 'package:meal_hisab/providers/mess_provider.dart';
import 'package:meal_hisab/providers/notice_provider.dart';
import 'package:provider/provider.dart';

class NoticeAndAnnouncementScreen extends StatefulWidget {
  const NoticeAndAnnouncementScreen({super.key});

  @override
  State<NoticeAndAnnouncementScreen> createState() => _NoticeAndAnnouncementScreenState();
}

class _NoticeAndAnnouncementScreenState extends State<NoticeAndAnnouncementScreen> {
  double posX = 0;
  double posY = 0;

  @override
  void initState() {
    super.initState();
    // Delay getting screen size until layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        posX = (size.width - 56) / 2; // Center horizontally (56 = FAB size)
        posY = size.height - 200; // Near bottom (adjust for AppBar & padding)
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    final noticeProvider = context.read<NoticeProvider>();
    final messProvider = context.read<MessProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    return Scaffold(
      body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.green,
                child: Expanded(
                  child: Container(
                    child: FutureBuilder(
                      future : noticeProvider.getNoticeList(
                        messId: authProvider.getUserModel!.currentMessId, 
                        onFail: (_ ) {},
                        uId: authProvider.getUserModel!.uId
                      ),
                      // future : Future.delayed(Duration(seconds: 1)),
                      builder: (context, AsyncSnapshot<List<NoticeModel>?> snapshot) {
                        bool showDesc = false;
                        if (snapshot.connectionState != ConnectionState.done) { // we can use here snapshot.hasdata also. but it's safe 
                          return Center(child: showCircularProgressIndicator());
                        }
                        else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } 
                        else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                          return Center(child: Text('No Data Found'));
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            NoticeModel noticeModel = snapshot.data![index];
                            return StatefulBuilder(
                              builder: (context, setLocalState) {
                                return Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.only(left: 8),
                                        onTap: () {
                                          setLocalState((){
                                            showDesc = !showDesc;
                                          });
                                        },
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.red,
                                        ),
                                        title: Text(noticeModel.title.toString()),
                                        subtitle: Text(DateFormat("hh:mm a dd-MM-yyyy").format(noticeModel.CreatedAt!.toDate().toLocal())),
                                        trailing: PopupMenuButton(
                                          icon: Icon(Icons.more_vert),
                                          itemBuilder: (context) =>[
                                            PopupMenuItem(
                                              value: 3,
                                              child: ListTile(
                                                title: Text("Pin To Home"),
                                                leading: Icon(Icons.push_pin_sharp,),
                                              ), 
                                              onTap: () {
                                                noticeProvider.pinToHome(
                                                  noticeModel: noticeModel, 
                                                  messId: authProvider.getUserModel!.currentMessId,
                                                  onFail: (p0) {
                                                    showSnackber(context: context, content: "Action Failed!\n$p0");
                                                  },
                                                  onSuccess: (){
                                                    showSnackber(context: context, content: "Pinded, Look AT Home.");
                                                  }
                                                );
                                              },
                                            ),
                                            PopupMenuItem(
                                              value: 0,
                                              child: ListTile(
                                                title: Text("Edit"),
                                                leading: Icon(Icons.edit, color: Colors.green,),
                                              ), 
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNotice(preNoticeModel: noticeModel,)));
                                              },
                                            ),
                                  
                                            PopupMenuItem(
                                              value: 1,
                                              // onTap: (){
                                              //   // if i use this function. we don't need to Navigator.pop()
                                              // },
                                              child: ListTile(
                                                title: Text("Delete"),
                                                leading: Icon(Icons.delete, color: Colors.red,),
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
                                                    await noticeProvider.deleteANotice(
                                                      messId: authProvider.getUserModel!.currentMessId, 
                                                      noticeId: noticeModel.noticeId, 
                                                      onFail: (message ) {
                                                        print("failed");
                                                        showSnackber(context: context, content: "Deletion Failed!\n$message");
                                                      },
                                                      onSuccess: (){
                                                        print("success");
                                                        setState(() {
                                                          showSnackber(context: context, content: "Deletion Successed.");
                                                        });
                                                      }
                                                    );
                                                  }
                                                },
                                              ), 
                                            ),
                                          ]
                                        ),
                                      ),
                                
                                      if(showDesc) Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(noticeModel.description),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            );
                          }, 
                        );
                      }
                    ),
                  ),
                ),
              ),
              
              (amIAdmin(messProvider: messProvider, authProvider: authProvider) || amIactmenager(messProvider: messProvider, authProvider: authProvider))?
              Positioned(
                left: posX,
                top: posY,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      posX += details.delta.dx;
                      posY += details.delta.dy;
                    });
                  },
                  child: FloatingActionButton(
                    onPressed: () async{
                      Navigator.push( context ,MaterialPageRoute(builder: (context)=>AddNotice()));
                    },
                    child: Icon(Icons.add),
                  )
                ),
              )
              :
              SizedBox.shrink(),
            ]
          )
    );
  }

}