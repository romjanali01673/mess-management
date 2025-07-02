import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/notice_model.dart';
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



// get ---------------------------------------------------------

  bool   get getIsLoading=> _isLoading;
  double get getBlance => (_totalDepositOfMess - _totalBazerCost + _remainingFundBlance);

  double get getMealRate{
    if(_totalMealOfMess==0){
      return _totalBazerCost;
    }
    return (_totalBazerCost/_totalMealOfMess);
  } 
  double get getMyTotalMeal => _myTotalMeal;
  double get getMyTotalDeposit =>_myTotalDeposit;
  double get getMyRemainingTk{
    return getMealRate * getMyTotalMeal;
  }
  double get getTotalMealOfMess => _totalMealOfMess;
  double get getTotalBazerCost =>  _totalBazerCost;
  double get getRemainingFundBlance => _remainingFundBlance;
  double get getTotalDepositOfMess => _totalDepositOfMess;

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
        setRemainingFundBlanc(value: blance);
      }
        print(blance);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
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
        setTotalMealOfMess(value: meal);
      }
        print(meal);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
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
        setTotalBazerCost(value: bazer);
      }
      print(bazer);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
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
        setTotalDepositOfMess(value: deposit);
      }
      print("mess deposit $deposit");
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setIsLoading(value: false);
    return deposit;
  }

  Future<double> getTotalDepositOfMember({required String messId,required String mealSessionId,required String uId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get my total deposit called");
    double deposit = 0.0;
    setIsLoading(value: true);
    try {
      QuerySnapshot querySnapshot =  await firebaseFirestore
        .collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.members)
        .doc(uId)
        .collection(Constants.listOfDepositTnx)
        .get();
      
      querySnapshot.docs.map((snapshot){
        print(snapshot.id);
        if(snapshot.exists && snapshot.data() != null){
          deposit += double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.amount]).toString());
        }
      }).toList();
      
      setMyTotalDeposit(value: deposit);
      
      print("my deposit $deposit");
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      print(e.toString()+"getTotalDepositOfMember");
    }  
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
      
      setMyTotalMeal(value: meal);
      
      print("my total meal $meal");
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      print(e.toString()+"getTotalMealOfMember");
    }  
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