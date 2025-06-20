import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_hisab/constants.dart';

class NoticeModel{
  String noticeId;
  String title;
  String description;
  Timestamp? CreatedAt;

  NoticeModel(
    { 
      required this.noticeId,
      required this.title,
      required this.description,
      this.CreatedAt
    }
  );

  factory NoticeModel.fromMap(Map<String , dynamic>data){
    return NoticeModel(
      noticeId: data[Constants.noticeId]?? "", 
      title: data[Constants.title]?? "", 
      description: data[Constants.description]?? "",
      CreatedAt: data[Constants.createdAt], 
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.noticeId: noticeId,
      Constants.title: title,
      Constants.description: description,
      Constants.createdAt: FieldValue.serverTimestamp(),
    };
  }


}