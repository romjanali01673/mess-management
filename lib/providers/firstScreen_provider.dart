import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/model/notice_model.dart';
class FirstScreenProvider extends ChangeNotifier{
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  double blance = 0;
  double _myTotalMeal = 0;
  double _myTotalDeposit = 0;

  double _totalMealOfMess = 0;
  double _totalBazerCost = 0;
  double _remainingFundBlance = 0;
  double _totalDepositOfMess = 0;

  NoticeModel? _pindNoticeForHome;

  List<Map<String,dynamic>> _allMemberDepositAmountList = [];
  // uid , meal
  Map<String,double> _allMemberMeal={};



// get ---------------------------------------------------------

  bool   get getIsLoading=> _isLoading;
  double get gettotalBlance => (_totalDepositOfMess - _totalBazerCost + _remainingFundBlance);
  double get getmealBlance => (_totalDepositOfMess - _totalBazerCost);

  double get getMealRate{
    if(_totalMealOfMess==0){
      return _totalBazerCost;
    }
    return (_totalBazerCost/_totalMealOfMess);
  } 
  double get getMyTotalMeal => _myTotalMeal;
  double get getMyTotalDeposit =>_myTotalDeposit;
  double get getMyRemainingTk{
    return _myTotalDeposit - (getMealRate * getMyTotalMeal);
  }
  double get getTotalMealOfMess => _totalMealOfMess;
  double get getTotalBazerCost =>  _totalBazerCost;
  double get getRemainingFundBlance => _remainingFundBlance;
  double get getTotalDepositOfMess => _totalDepositOfMess;

  List<Map<String,dynamic>> get getAllMemberDepositAmountList => _allMemberDepositAmountList;
  Map<String,double> get getAllMemberMealCountList => _allMemberMeal;

  NoticeModel? get  getPindedNoticeForHome=> _pindNoticeForHome;



// set ---------------------------------------------------------

  void setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }

  void setMyTotalMeal({required double value}){
    _myTotalMeal = value;
    notifyListeners();
  }

  void setMyTotalDeposit({required double value}){
    _myTotalDeposit = value;
    notifyListeners();
  }

  void setTotalMealOfMess({required double value}){
    _totalMealOfMess = value;
    notifyListeners();
  }

  void setTotalBazerCost({required double value}){
    _totalBazerCost =value;
    notifyListeners();
  }

  void setRemainingFundBlanc({required double value}){
    _remainingFundBlance = value;
    notifyListeners();
  }

  void setTotalDepositOfMess({required double value}){
    _totalDepositOfMess = value;
    notifyListeners();
  }

  void setPindNoticeForHome({required NoticeModel? value}){
    _pindNoticeForHome = value;
    notifyListeners();
  }


  void reset(){
    _isLoading = false;
    blance = 0;
    _myTotalMeal = 0;
    _myTotalDeposit = 0;
    _totalMealOfMess = 0;
    _totalBazerCost = 0;
    _remainingFundBlance = 0;
    _totalDepositOfMess = 0;
    _pindNoticeForHome = null;
  }



  Future<void> getAllMemberDepositAmount({required String messId,required String mealSessionId, required Function(String) onFail, Function()? onSuccess,})async{
    print("called getAllMemberDepositAmount");
    _allMemberDepositAmountList = [];
    setIsLoading(value: true);
    try {
      QuerySnapshot querySnapshot =  await firebaseFirestore
        .collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.members)
        .get();

        querySnapshot.docs.map((doc){
          _allMemberDepositAmountList.add({
            Constants.amount : (doc.data() as Map<String, dynamic>)[Constants.blance],
            Constants.uId : doc.id,
          });
        }).toList();

      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setIsLoading(value: false);
  }

  Future<void> getAllMemberMeal({required String messId,required String mealSessionId, required Function(String) onFail, Function()? onSuccess,})async{
    print("called getAllMemberMeal");
    _allMemberMeal = {};
    setIsLoading(value: true);
    try {
      QuerySnapshot querySnapshot =  await 
        firebaseFirestore
        .collection(Constants.meal)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.listOfMealTnx)
        .get();
      
      querySnapshot.docs.map((snapshot){
        if(snapshot.exists && snapshot.data() != null){
          (((snapshot.data() as Map<String,dynamic>)[Constants.listOfMeal]) as List<dynamic>).map((x){
            Map<String,dynamic> mp = x as Map<String,dynamic>;

            _allMemberMeal[mp[Constants.uId]] = (_allMemberMeal[mp[Constants.uId]] ?? 0) + double.parse(mp[Constants.meal].toString());
          }).toList();
        }
      }).toList();
                  
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString()+" getAllMemberMeal");
    }  
    setIsLoading(value: false);
  }

  Future<double> getFundBlance({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("called total fund");
    double blance = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore
        .collection(Constants.fund)
        .doc(messId)
        .get();

      if(snapshot.exists && snapshot.data() != null){
        blance = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());
      }
        print(blance);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setRemainingFundBlanc(value: blance);
    setIsLoading(value: false);
    return blance;
  }
  Future<double> getTotalMeal({required String messId,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get total meal called");
    double meal = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await 
      firebaseFirestore
        .collection(Constants.meal)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .get();

      if(snapshot.exists && snapshot.data() != null){
        meal = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.totalMeal]).toString());
      }
        print(meal);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setTotalMealOfMess(value: meal);
    setIsLoading(value: false);
    return meal;
  }
  Future<double> getTotalBazer({required String messId,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get total bazer called");
    double bazer = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await 
        firebaseFirestore
        .collection(Constants.bazer)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .get();

      if(snapshot.exists && snapshot.data() != null){
        bazer = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.totalBazerCost]).toString());
      }
      print(bazer);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setTotalBazerCost(value: bazer);
    setIsLoading(value: false);
    return bazer;
  }
  
  Future<double> getTotalDeposit({required String messId ,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get total deposit called");
    double deposit = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore
        .collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .get();


      if(snapshot.exists && snapshot.data() != null){
        deposit = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());
      }
      print("mess deposit $deposit");
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setTotalDepositOfMess(value: deposit);
    setIsLoading(value: false);
    return deposit;
  }

  Future<double> getTotalDepositOfMember({required String messId,required String mealSessionId,required String uId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get my total deposit called");
    double deposit = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot= await firebaseFirestore.collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.members)
        .doc(uId)
        .get();
      

      deposit += double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());      
      
      print("my deposit $deposit");
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      print(e.toString()+"getTotalDepositOfMember");
    }  
    setMyTotalDeposit(value: deposit);
    setIsLoading(value: false);
    return deposit;
  }


  Future<double> getTotalMealOfMember({required String messId,required String mealSessionId,required String uId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get my total meal called");
    double meal = 0.0;
    setIsLoading(value: true);
    try {
      QuerySnapshot querySnapshot =  await firebaseFirestore
        .collection(Constants.meal)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.listOfMealTnx)
        .get();
      
      querySnapshot.docs.map((snapshot){
        print(snapshot.id);
        if(snapshot.exists && snapshot.data() != null){
          (((snapshot.data() as Map<String,dynamic>)[Constants.listOfMeal]) as List<dynamic>).map((x){
            Map<String,dynamic> mp = x as Map<String,dynamic>;
            if(mp[Constants.uId]==uId){
              meal += double.parse(mp[Constants.meal].toString());
            }
          }).toList();
        }
      }).toList();
      
      
      print("my total meal $meal");
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      print(e.toString()+"getTotalMealOfMember");
    }  
    setMyTotalMeal(value: meal);
    setIsLoading(value: false);
    return meal;
  }

  Future<NoticeModel?> getPindNoticeForHomeFromDatabase({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("getPindedNotice called");
    setIsLoading(value: true);
    try {
      NoticeModel? noticeModel;
      DocumentSnapshot snapshot =  await 
      firebaseFirestore
      .collection(Constants.notice)
      .doc(messId)
      .get();
      
    
      if(snapshot.exists && snapshot.data() != null){
        if((snapshot.data()as Map<String,dynamic>)[Constants.homePindedNotice] !=null){
          noticeModel = NoticeModel.fromMap(((snapshot.data()as Map<String,dynamic>)[Constants.homePindedNotice] as Map<String,dynamic>));
        }
        if((snapshot.data() as Map<String,dynamic>)[Constants.messMemberList] !=null){
        }
      }
    
      setPindNoticeForHome(value: noticeModel);
      
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      print(e.toString()+"getPindedNotice");
    }  
    setIsLoading(value: false);
    return null;
  }

}