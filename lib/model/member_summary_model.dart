import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class MemberSummaryModel {

  String fname;
  String uId;

  String mealSessionId;
  String messId;
  String messName;
  Timestamp? joindAt;
  Timestamp? closedAt;

  double totalMeal;
  double totalDeposit;
  double remaining;

  double mealRate;
  double totalMealOfMess;
  double totalBazerCost;
  double currentFundBlance;

  String status;


  MemberSummaryModel( {
    required this.fname,
    required this.uId,

    required this.mealSessionId,
    required this.messId,
    required this.messName,      
    this.joindAt,
    this.closedAt,

    required this.totalMeal, 
    required this.totalDeposit, 
    required this.remaining, 

    required this.totalMealOfMess,
    required this.mealRate, 
    required this.totalBazerCost, 
    required this.currentFundBlance, 
    this.status = Constants.Temporary
  });

  Map<String,dynamic> toMap(){
    return{
      Constants.fname: fname,
      Constants.uId: uId,

      Constants.mealSessionId: mealSessionId,
      Constants.messId:messId,
      Constants.messName: messName,
      Constants.joindAt:joindAt?? FieldValue.serverTimestamp(),
      Constants.closedAt:closedAt?? FieldValue.serverTimestamp(),

      Constants.totalMeal : totalMeal,
      Constants.totalDeposit : totalDeposit,
      Constants.remaining : remaining,

      Constants.mealRate : mealRate,
      Constants.totalMealOfMess : totalMealOfMess,
      Constants.totalBazerCost : totalBazerCost,
      Constants.currentFundBlance : currentFundBlance,

      Constants.status : status,
    };
  }

  factory MemberSummaryModel.fromMap(Map<String,dynamic>data){
    return MemberSummaryModel(
      fname: data[Constants.fname]??"",
      uId: data[Constants.uId]??"",
      mealSessionId: data[Constants.mealSessionId]??"",
      messId: data[Constants.messId]?? "", 
      messName: data[Constants.messName] ??"", 
      joindAt: data[Constants.joindAt]?? Timestamp.fromDate(DateTime.now()), 
      closedAt: data[Constants.closedAt]?? Timestamp.fromDate(DateTime.now()), 
      
      totalMeal: data[Constants.totalMeal] ??0, 
      totalDeposit: data[Constants.totalDeposit]??0, 

      remaining: data[Constants.remaining]??0, 
      mealRate: data[Constants.mealRate]??0, 
      totalBazerCost:data[Constants.totalBazerCost]?? 0, 
      currentFundBlance:data[Constants.currentFundBlance]?? 0, 
      totalMealOfMess: data[Constants.totalMealOfMess]??0, 
      
      status: data[Constants.status]?? Constants.Temporary,
    );
  }

}