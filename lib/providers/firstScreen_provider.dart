import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
class FirstScreenProvider extends ChangeNotifier{
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  double _myTotalMeal = 0;
  double _myTotalDeposit = 0;

  double _totalMealOfMess = 0;
  double _totalBazerCost = 0;
  double _remainingFandBlance = 0;
  double _totalDepositOfMess = 0;



// get ---------------------------------------------------------

  bool   get getIsLoading=> _isLoading;

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
  double get getRemainingFandBlance => _remainingFandBlance;
  double get getTotalDepositOfMess => _totalDepositOfMess;

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

  void setRemainingFandBlanc({required double value}){
    _remainingFandBlance = value;
    notifyListeners();
  }

  void setTotalDepositOfMess({required double value}){
    _totalDepositOfMess = value;
    notifyListeners();
  }


  Future<double> getFandBlance({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("called total fand");
    double blance = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.fand).doc(messId).get();
      if(snapshot.exists && snapshot.data() != null){
        blance = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());
        setRemainingFandBlanc(value: blance);
      }
        print(blance);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setIsLoading(value: false);
    return blance;
  }
  Future<double> getTotalMeal({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get total meal called");
    double meal = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.meal).doc(messId).get();
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
  Future<double> getTotalBazer({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get total bazer called");
    double bazer = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.bazer).doc(messId).get();
      if(snapshot.exists && snapshot.data() != null){
        bazer = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.cost]).toString());
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
  
  Future<double> getTotalDeposit({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get total deposit called");
    double deposit = 0.0;
    setIsLoading(value: true);
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.deposit).doc(messId).get();
      if(snapshot.exists && snapshot.data() != null){
        deposit = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.deposit]).toString());
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

  Future<double> getTotalDepositOfMember({required String messId,required String uId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get my total deposit called");
    double deposit = 0.0;
    setIsLoading(value: true);
    try {
      QuerySnapshot querySnapshot =  await firebaseFirestore.collection(Constants.deposit).doc(messId).collection(Constants.member).doc(uId).collection(Constants.listOfDepositTransactions).get();
      
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
      print(e.toString());
    }  
    setIsLoading(value: false);
    return deposit;
  }


  Future<double> getTotalMealOfMember({required String messId,required String uId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get my total meal called");
    double meal = 0.0;
    setIsLoading(value: true);
    try {
      QuerySnapshot querySnapshot =  await firebaseFirestore.collection(Constants.meal).doc(messId).collection(Constants.listOfMeal).get();
      
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
      print(e.toString());
    }  
    setIsLoading(value: false);
    return meal;
  }

}