import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class PreDataMemberModel{
  String tnxId;
  String uid;
  String fname;
  String messId;
  double totalDeposit;
  double totalMeal;
  String email;
  String phone;
  String fullAddress;
  Timestamp? createdAt;

  PreDataMemberModel(
    { 
      required this.tnxId,
      required this.uid,
      required this.fname,
      required this.messId,
      required this.totalDeposit,
      required this.totalMeal,
      required this.email,
      required this.phone,
      required this.fullAddress,
      this.createdAt,
    }
  );

  factory PreDataMemberModel.fromMap(Map<String , dynamic>data){
    return PreDataMemberModel(
      tnxId: data[Constants.tnxId]??"",
      uid: data[Constants.uId]??"",
      fname: data[Constants.fname]??"",
      messId: data[Constants.messId]??"",
      totalDeposit: data[Constants.totalDeposit]??0,
      totalMeal: data[Constants.totalMeal]??0,
      email: data[Constants.email]??"",
      phone: data[Constants.phone]??"", 
      fullAddress: data[Constants.fullAddress]??"", 
      createdAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()),
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.tnxId: tnxId,
      Constants.uId: uid,
      Constants.fname: fname,
      Constants.messId: messId,
      Constants.totalDeposit: totalDeposit,
      Constants.totalMeal: totalMeal,
      Constants.email: email,
      Constants.phone: phone, 
      Constants.fullAddress: fullAddress, 
      Constants.createdAt: FieldValue.serverTimestamp(),
    };
  }
}