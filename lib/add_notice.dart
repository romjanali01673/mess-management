import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/home.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/fund_model.dart';
import 'package:mess_management/model/notice_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/fund_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/providers/notice_provider.dart';
import 'package:provider/provider.dart';

class AddNotice extends StatefulWidget {
  final NoticeModel? preNoticeModel;
  const AddNotice({super.key, this.preNoticeModel});

  @override
  State<AddNotice> createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  final formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

@override
  void initState() {
    if(widget.preNoticeModel!=null){
      titleController.text = widget.preNoticeModel!.title;
      descController.text = widget.preNoticeModel!.description;
    }
    // TODO: implement 

    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    bool isUpdate = (widget.preNoticeModel!=null);

    NoticeProvider noticeProvider = context.watch<NoticeProvider>();
    AuthenticationProvider authProvider = context.read<AuthenticationProvider>();
    MessProvider messProvider = context.read<MessProvider>();

    
    return GestureDetector(
      onTap: (){FocusScope.of(context).unfocus();},
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          title: Text("Add Notice & Announcement"),
          backgroundColor: Colors.grey,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleController,
                        // onTapOutside: (event) {// close keyboard
                        //   FocusScope.of(context).unfocus();
                        // },
                        
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        validator: (value) {
                          return titleValidator(value.toString());
                        },
                        decoration: InputDecoration(
                          label: Text("Title"),
                          border: OutlineInputBorder(
                          
                          )
                        )
                      ),
                    ),
              
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: descController,
                        // onTapOutside: (event) {// close keyboard
                        //   FocusScope.of(context).unfocus();
                        // },
                        maxLines: 10,
                        textInputAction: TextInputAction.newline,
                        validator: (value) {
                          return descValidator(value.toString());
                        },
                        decoration: FromFieldDecoration(
                          hintText: "Write Details about",
                          label: "Description ",
                        )
                      ),
                    ),
         
                  ],
                ),
              ),
        
              SizedBox(
                height: 50,
              ),
        
              noticeProvider.isLoading? 
              SizedBox.square(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              )
              :
              noticeProvider.isLoading? showCircularProgressIndicator()
              : 
              getButton(
                label: isUpdate ? "Update":"Submit", 
                ontap: ()async{
                  bool valided  = formKey.currentState!.validate();
                  if(valided){
                    if(amIAdmin(messProvider: messProvider, authProvider: authProvider)||amIactmenager(messProvider: messProvider, authProvider: authProvider)){
                      // add a transaction to datebase 
                      if(isUpdate){
                        await noticeProvider.updateANotice(
                          noticeModel: NoticeModel(
                            noticeId: widget.preNoticeModel!.noticeId, 
                            title: titleController.text.toString(), 
                            description: descController.text.toString(),
                            CreatedAt: widget.preNoticeModel!.CreatedAt,
                          ), 
                          currentMessMemberUidList: messProvider.
                            getMessModel!.
                            messMemberList.map((x){
                               return x[Constants.uId].toString();
                            }).toList(),
                          messId: authProvider.getUserModel!.currentMessId, 
                          onFail: (message) {  
                            showSnackber(context: context, content: "Sonthing Wrong, Try Again!\n$message");
                          },
                          onSuccess: (){
                            showSnackber(context: context, content: "Updatation Successed");
                            Navigator.pop(context);
                          }
                        );
                      }
                      else{
                        await noticeProvider.addANotice(
                          noticeModel: NoticeModel(
                            noticeId: DateTime.now().millisecondsSinceEpoch.toString(), 
                            title: titleController.text.toString().trim(), 
                            description: descController.text.toString().trim(),
                          ), 
                          currentMessMemberUidList: messProvider.
                            getMessModel!.
                            messMemberList.map((x){
                               return x[Constants.uId].toString();
                            }).toList(),                          messId: authProvider.getUserModel!.currentMessId, 
                          onFail: (message) {  
                            showSnackber(context: context, content: "Sonthing Wrong, Try Again!\n$message");
                          },
                          onSuccess: (){
                            showSnackber(context: context, content: "Notice Added Successfully");
                            noticeProvider.sendNotification(
                              messProvider,
                              title: "Menager Added a New Notice",
                              body: titleController.text.toString().trim(),
                              data: {},
                            );
                            Navigator.pop(context);
                          }
                        );
                      }
                    }
                    else{
                      showSnackber(context: context, content: "required meneger power");
                    }
                  }
                  else{
                    showSnackber(context: context, content: "please, fill add required field!");
                  }
                },
              ),
              SizedBox(
                height: 300,
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}


// fund -> mess_id -> transactions -> transaction_id ->  {id, amount, title, description, time, type{"add", "sub"}, }