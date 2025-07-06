import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class MessSummaryModel {

  String mealSessionId;
  String messId;
  String messName;
  Timestamp? joindAt;
  Timestamp? closedAt;
  List<Map<String,dynamic>> messMemberList;

  double remaining; // fund+deposit-bazer
  
  double mealRate;
  double totalDeposit;
  double totalMealOfMess;
  double totalBazerCost;
  double currentFundBlance;

  String status;


  MessSummaryModel( {
    required this.mealSessionId,
    required this.messId,
    required this.messName,    
    required this.messMemberList,  
    this.joindAt,
    this.closedAt,

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
      Constants.mealSessionId: mealSessionId,
      Constants.messId:messId,
      Constants.messName: messName,
      Constants.messMemberList: messMemberList,
      Constants.joindAt:joindAt?? FieldValue.serverTimestamp(),
      Constants.closedAt:closedAt?? FieldValue.serverTimestamp(),

      Constants.totalDeposit : totalDeposit,
      Constants.remaining : remaining,

      Constants.mealRate : mealRate,
      Constants.totalMealOfMess : totalMealOfMess,
      Constants.totalBazerCost : totalBazerCost,
      Constants.currentFundBlance : currentFundBlance,

      Constants.status : status,
    };
  }

  factory MessSummaryModel.fromMap(Map<String,dynamic>data){
    return MessSummaryModel(
      mealSessionId: data[Constants.mealSessionId]??"",
      messId: data[Constants.messId]?? "", 
      messName: data[Constants.messName] ??"", 
      messMemberList: ((data[Constants.messMemberList]??[]) as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [],      
      joindAt: data[Constants.joindAt]?? Timestamp.fromDate(DateTime.now()), 
      closedAt: data[Constants.closedAt]?? Timestamp.fromDate(DateTime.now()), 
      
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