import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class PreDataMessModel{
  String tnxId;
  String messId;
  String messName;
  double totalDeposit;
  double currentFundBlance;
  double totalMeal;
  double totalBazerCost; 
  List<Map<String,dynamic>>   messMemberList;
  double mealRate;
  String email;
  String phone;
  String fullAddress;
  Timestamp? createdAt;


  PreDataMessModel(
    { 
      required this.tnxId,
      required this.messId,
      required this.messName,
      required this.totalDeposit,
      required this.currentFundBlance,
      required this.totalMeal,
      required this.totalBazerCost,
      required this.messMemberList,
      required this.mealRate,
      required this.email,
      required this.phone,
      required this.fullAddress,
      this.createdAt,
    }
  );

  factory PreDataMessModel.fromMap(Map<String , dynamic>data){
    return PreDataMessModel(
      tnxId: data[Constants.tnxId]??"",
      messId: data[Constants.messId]??"",
      messName: data[Constants.messName]??"", 
      totalDeposit: data[Constants.totalDeposit]??0,
      currentFundBlance: data[Constants.currentFundBlance]??0,
      totalMeal: data[Constants.totalMeal]??0,
      totalBazerCost: data[Constants.totalBazerCost]??0, 
      messMemberList: data[Constants.messMemberList]??[],
      mealRate: data[Constants.mealRate]??0,
      email: data[Constants.email]??"",
      phone: data[Constants.phone]??"", 
      fullAddress: data[Constants.fullAddress]??"", 
      createdAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()),
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.tnxId: tnxId,
      Constants.messId: messId,
      Constants.messName: messName, 
      Constants.totalDeposit: totalDeposit,
      Constants.currentFundBlance: currentFundBlance,
      Constants.totalMeal: totalMeal,
      Constants.totalBazerCost: totalBazerCost, 
      Constants.messMemberList: messMemberList,
      Constants.mealRate: mealRate,
      Constants.email: email,
      Constants.phone: phone, 
      Constants.fullAddress: fullAddress, 
      Constants.createdAt: FieldValue.serverTimestamp(),
    };
  }
}