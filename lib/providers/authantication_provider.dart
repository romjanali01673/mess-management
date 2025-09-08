import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage firebaseStorage= FirebaseStorage.instance;
  final FirebaseFirestore firebaseFirestore= FirebaseFirestore.instance;
  StreamSubscription ? _messSubscription;

  bool _isLoading = false;
  bool _isSignedIn = false;

  UserModel? _userModel;

  // get ---------------------

  bool get isLoading => _isLoading;
  String? get getUid {
    return _userModel?.uId;
  }
  UserModel? get getUserModel=> _userModel;

  // set -------------------


  Future<void> setSignedIn ({required bool val, })async{
    print("s1");
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    print("s2");

    await sharedPreferences.setBool(Constants.isSignedIn, val);
    _isSignedIn = val;
    
    notifyListeners();
  }

  void setLoading({required bool val}){
    _isLoading = val;
    notifyListeners();
  }

  void setUid({required String uId}){
    if(_userModel==null){
      _userModel = UserModel.fromMap({Constants.uId : uId});
    }
    else{
      _userModel!.uId = uId;
    }
  }

  void setUserModel({   
    String ? uId,
    String ? fname,
    String ? email,
    String ? image,
    String ? number,
    String ? sessionKey,
    String ? currentMessId,
    String ? mealSessionId,
    Timestamp ? createdAt,
  }){

    _userModel!.uId = uId?? _userModel!.uId;
    _userModel!.fname = fname?? _userModel!.fname;
    _userModel!.email = email?? _userModel!.email;
    _userModel!.image = image?? _userModel!.image;
    _userModel!.number = number?? _userModel!.number;
    _userModel!.sessionKey = sessionKey??  _userModel!.sessionKey;
    _userModel!.currentMessId = currentMessId??  _userModel!.currentMessId;
    _userModel!.mealSessionId= mealSessionId??  _userModel!.mealSessionId;
    _userModel!.createdAt = createdAt??  _userModel!.createdAt;
    
    notifyListeners();
  }

  void reset(){
    setSignedIn(val: false);
    _userModel = null;
  }



  // function here ---------------------------------------
  
  void listenMyProfile({required String uId}){
    _messSubscription?.cancel(); // পুরানো subscription থাকলে বন্ধ করো

    try {
      _messSubscription = firebaseFirestore
        .collection(Constants.users)
        .doc(getUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _userModel = UserModel.fromMap(data);
        notifyListeners();
        debugPrint("listenTomy Profile-1" +"notifyListener called");
      }
    });
    } catch (e) {
      
    }
  }


  // store uid to firestore
  // authToken we will get from userCurdential.user!.uid
  Future<void> storeUid ({required String authToken, required String uid,required Function(String) onFail})async{
    try {
      await firebaseFirestore.collection(Constants.uId).doc(authToken).set({Constants.uId:uid});
      setUid(uId: uid);
      notifyListeners();
    } catch (e) {
      onFail(e.toString());
    }
  }

  Future<void> getUidFromFiretore ({ required Function(String) onFail})async{
    try {
      // after successfully login we can access "firebaseAuth.currentUser!.uid"
      DocumentSnapshot snapshot = await firebaseFirestore
        .collection(Constants.uId)
        .doc(firebaseAuth.currentUser!.uid)//"firebaseAuth.currentUser" it's stored local memory (in rom). so we can access it untill cashed was not cleared or logout.
        .get();
      setUid(uId: snapshot[Constants.uId]);
      debugPrint(snapshot[Constants.uId].toString()+ "get uid from firestore");
      notifyListeners();
    } catch (e) {
      onFail(e.toString());
    }
  }

  Future<bool> checkIsSubcscraiber()async{
    bool flg = false;
    try {
      var x   = await firebaseFirestore
      .collection("update")
      .doc("x")
      .get();

      flg = x.data()!["key"]=='1234';

    } catch (e) {
      
    }

    return flg;
  }

  Future<void> sessionValid({required Function(bool) onSuccess,required Function(String) onFail})async{
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String StringUserModel =  await sharedPreferences.getString(Constants.userModel).toString();
      // get from firestore
      Map<String,dynamic> mp = jsonDecode(StringUserModel);
      // convart datetime.tostringiso to timestarp
      mp[Constants.createdAt]=  Timestamp.fromDate(DateTime.parse(mp[Constants.createdAt]));

      UserModel userM = UserModel.fromMap(mp);

      onSuccess(userM.sessionKey == getUserModel!.sessionKey);

      print(getUserModel!.sessionKey+"firestore");
      print(userM.sessionKey+"shared pref");
    } catch (e) {
      onFail(e.toString());
    }
  }


  // set session key to firestore
  Future<void> setSessionKey({required Function(String) onFail,Function()? onSuccess})async{
    try {
      setUserModel(sessionKey: DateTime.now().millisecondsSinceEpoch.toString());

      firebaseFirestore 
        .collection(Constants.users)
        .doc(getUid)
        .set(
          
          getUserModel!.toMap(),
          
          SetOptions(
            mergeFields: [Constants.sessionKey],
          ),
        );
        onSuccess?.call();
    } catch (e) {
      onFail(e.toString());
    }
  }

  //check is Sign In
  Future<bool> checkIsSignedIn()async{
    final SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    _isSignedIn =  sharedPreferences.getBool(Constants.isSignedIn) ?? false;
    notifyListeners();
    debugPrint(_isSignedIn.toString());
    return _isSignedIn;

  }

  // store userprofile data to shared preference
  Future<bool> saveUserDataToSharedPref()async{
    debugPrint("1");
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      Map<String,dynamic> mp = getUserModel!.toMap(); 
      mp[Constants.createdAt] = getUserModel!.createdAt!.toDate().toIso8601String();
      await sharedPreferences.setString(Constants.userModel, jsonEncode(mp));
    debugPrint("2");
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  // change password
  Future<void> changePassword({required String currentPass, required String newPass, Function()? onSuccess, required Function(String) onFail})async{
    setLoading(val: true);
    try {
      await Future.delayed(Duration(seconds: 3));
      bool valid = await checkUserIsValid(email: getUserModel!.email, password: currentPass);
      if(valid){
        debugPrint("valid data");
        await firebaseAuth.currentUser!.updatePassword(newPass);
        onSuccess!=null? onSuccess(): (){};
      }
      else{
        onFail("Wrong Password!");
      }
    } catch (e) {
      setLoading(val: false);
      onFail(e.toString());
    }
    debugPrint("done");
    setLoading(val: false);
  }


  Future<void> setDeviceToken(String? token, {Function(String)? onFail})async{
    try {
      debugPrint("Device Token hase called");
      await firebaseFirestore
      .collection(Constants.users)
      .doc(getUid)
      .set(
        {Constants.deviceId : token}, 
        SetOptions(merge: true)
      );
      debugPrint("Device Token hase done");
    } catch (e) {
      onFail?.call(e.toString());
      debugPrint("Device Token hase error: $e");
    }
  }

  // check user exist
  Future<bool> getUserProfileData({required Function(String) onFail, bool isFromServer = false})async{
    // way 1
    // await firebaseFirestore.collection(Constants.users).doc(uid).get().then((DocumentSnapshot documentSnapshot){
      // _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    // });
    // way 2
    DocumentSnapshot? documentSnapshot;
    try{
      debugPrint(getUid.toString()+"getUserProfileData");
      documentSnapshot = await firebaseFirestore
        .collection(Constants.users)
        .doc(getUid) 
        .get( GetOptions( source: isFromServer? Source.server : Source.serverAndCache)); 
    }catch (e){
      onFail(e.toString()+"getUserProfileData");
      return false;
    }
    if(documentSnapshot.exists && documentSnapshot.data() !=null ){
      // user exist 
      _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      debugPrint("getUserProfileData" + "${documentSnapshot.data().toString()}");
    return true;
    }
    else{
      return false;
    }
  }

  // get a spacific user data
  Future<UserModel?> getMemberData({required String uId})async{
    try {
        DocumentSnapshot snapshot = await firebaseFirestore.collection(Constants.users).doc(uId).get();
      if(snapshot.exists && snapshot.data()!=null){
        return UserModel.fromMap(snapshot.data() as Map<String,dynamic>);
      }
    } catch (e) {
      e.toString();
    }
    return null;
  }
  
  // signIn with email and password
  Future<UserCredential?> signInWithEmailAndPassword({required String email, required String password,required Function(String) onFail, Function()? onSuccess})async{
    UserCredential? userCredential;
    try {
      userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      //"firebaseAuth.currentUser!.uid" it's stored local memory (in rom). so we can access it untill cashed was not cleared or logout.
      onSuccess!= null? onSuccess():(){};
    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found') {
        onFail("User Not Found");
      } else if(e.code == 'wrong-password') {
        onFail("Wrong Password");
      } else {
        onFail( "Wrong Email or Password\n" + e.message.toString());
      }
    }catch (e) {
      onFail(e.toString());
    }
    return userCredential;
  }

  // signIn with email and password
  Future<bool> checkUserIsValid({required String email, required String password,Function(String)? onFail, Function()? onSuccess})async{
    UserCredential? userCredential;
    try {
      userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      onSuccess?.call();
    } catch (e) {
      if(onFail!=null){
        onFail(e.toString());
      }
      return false; 
    }

    if(userCredential!=null && userCredential.user != null){
      return true;
    }
    return false;
  }

  // delete usr pre auth account
  Future<bool> deletePreAuthAccount({required String email, required String password,required Function(String) onFail, Function()? onSuccess})async{
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      await firebaseAuth.currentUser!.delete();
      onSuccess!= null? onSuccess():(){};
      return true;
    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found') {
        onFail("User Not Found");
      } else if(e.code == 'wrong-password') {
        onFail("Wrong Password");
      } else {
        onFail( "Wrong Email or Password\n" + e.message.toString());
      }
    }catch (e) {
      onFail(e.toString());
    }
    return false;
  }


  // create a user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({required String email, required String password, required Function(String) onFail})async{
    setLoading(val:true);
    UserCredential? userCredential;
    try {
      userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      setLoading(val: false);
      onFail(e.toString());
      notifyListeners();
    }
    return userCredential;
  }

  // save user data to Firestore database
  Future<void> saveUserDataToFireStore({
    required UserModel currentUser,
    required File? fileImage,
    required Function() onSuccess,
    required Function(String) onFail,
  })async{
    try{
      if(fileImage!=null){
        // upload image to firestore storage and  assign the given link in currentUser
        String imageUrl = await storeFileImageToStorage(
          ref: "${Constants.userImages}/$getUid",
          file: fileImage,
          onFail: (val){
            // image up failed
          }
        );
        currentUser.image = imageUrl;
      } 
      _userModel = currentUser;

      // save data to firestore
      await firebaseFirestore
        .collection(Constants.users)
        .doc(getUid)
        .set(currentUser.toMap());

      onSuccess();

    }catch(e){
        onFail(e.toString());
        setLoading(val: false);
    }
    setLoading(val: false);
  }



  // update user data from Firestore database
  // and update user name to current mess in member list.
  Future<void> updateUserDataToFireStore({
    required UserModel currentUser,
    required File? fileImage,
    required Function() onSuccess,
    required Function(String) onFail,
  })async{
    final batch = firebaseFirestore.batch();
    
    try{
      if(fileImage!=null){
        // upload image to firestore storage and  assign the given link in currentUser
        String imageUrl = await storeFileImageToStorage(
          ref: "${Constants.userImages}/$getUid",
          file: fileImage,
          onFail: (val){
            // image up failed
          }
        );
        currentUser.image = imageUrl;
      } 

      _userModel = currentUser;


      // get my current data in my mess
      Map<String, dynamic> myCurrentDataInMess = {};
      Map<String, dynamic> myWantedDataInMess = {
        Constants.fname : currentUser.fname,
        Constants.uId : currentUser.uId,
      };
      if(currentUser.currentMessId != ""){ // update if i am connected to any mess
      
        DocumentSnapshot snapshot = await firebaseFirestore.collection(Constants.mess).doc(currentUser.currentMessId).get(); 
        if(snapshot.exists && snapshot.data()!= null){
          (((snapshot.data() as Map<String,dynamic>)[Constants.messMemberList]) as List<dynamic>).map((x){
            if(x[Constants.uId]==currentUser.uId){
        debugPrint(((snapshot.data() as Map<String,dynamic>)[Constants.messMemberList]).toString());

              myWantedDataInMess[Constants.status] = x[Constants.status];
              myCurrentDataInMess = x ;
            }
          }).toList();
        }
      }

      // update data to firestore
      batch.update(
        firebaseFirestore
        .collection(Constants.users)
        .doc(currentUser.uId),
        
        currentUser.toMap()
      );

      
      if(currentUser.currentMessId != ""){ // update if i am connected to any mess
        // delete current data from mess
        batch.update(
          firebaseFirestore
          .collection(Constants.mess)
          .doc(currentUser.currentMessId),        
          {Constants.messMemberList : FieldValue.arrayRemove([myCurrentDataInMess])},
        );

        // add new data to mess
        batch.update(// if use update here we see only push data pre stored data will be lost.
          firebaseFirestore
          .collection(Constants.mess)
          .doc(currentUser.currentMessId),        
          {Constants.messMemberList : FieldValue.arrayUnion([myWantedDataInMess])},
        );
      }


      await batch.commit();

      onSuccess();

    }catch(e){
        onFail(e.toString());
        debugPrint(e.toString());
        setLoading(val: false);
    }
    setLoading(val: false);
  }

  // forget password
  Future<void> forgetPassword({required String email})async{
    debugPrint("pass rest called");
    try {
      firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  // update user data from Firestore database
  // and update user name to current mess in member list.
  Future<void> updateMemberEmail({
    required String preEmail,
    required String email,
    required String password,
    Function()? onSuccess,
    required Function(String) onFail,
  })async{
    final batch = firebaseFirestore.batch();
    // create a user account in authentication
    setLoading(val:true);
    String preAuthToken = firebaseAuth.currentUser!.uid;

    UserCredential? userCredential;
    userCredential = await signInWithEmailAndPassword(email: getUserModel!.email, password: password, onFail:onFail);
    if(userCredential!=null && userCredential.user !=null){
      userCredential = null;
      try {
        userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        setLoading(val: false);
        onFail(e.toString());
        notifyListeners();
      }

      if(userCredential!=null && userCredential.user != null){
        try{
          // delete pre authToken from uid
          batch.delete(
            firebaseFirestore
            .collection(Constants.uId)
            .doc(preAuthToken)
          );

          // set new authToken in uid
          batch.set(
            firebaseFirestore
            .collection(Constants.uId)
            .doc(userCredential.user!.uid), // as auth tocken
            
            {Constants.uId : getUserModel!.uId}
          );


          // set new email in firestore
          batch.update(
            firebaseFirestore
            .collection(Constants.users)
            .doc(getUserModel!.uId),        
            {Constants.email : email}
          );

        

          await batch.commit();
          setUserModel(email: email);

          await deletePreAuthAccount(email: preEmail, password: password, onFail: (_){});
          await firebaseAuth.signOut();
          await signInWithEmailAndPassword(email: email, password: password, onFail: (_){});
          onSuccess!= null ?onSuccess():(){};

        }catch(e){
            onFail(e.toString());
            debugPrint(e.toString());
            setLoading(val: false);
        }         
      }

    } 
    setLoading(val: false);
  }


  // store file to firebase storage
  Future<String> storeFileImageToStorage({
    required String ref,
    required File file,
    required Function(String) onFail,
  })async{
    try {
      UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      onFail(e.toString());
    }
    return "";
  }


}