
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/authantication/sign_in.dart';
import 'package:meal_hisab/model/user_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
  GlobalKey<FormState> fromKey = GlobalKey<FormState>();
  String pass  = "";
  String Fname = "";
  String email = "";
  String phone = "";




  // sign up here
  void signUp()async{
    if(fromKey.currentState!.validate()){
      // debugPrint("Singup---------");
      // debugPrint(pass);
      // debugPrint(Fname);
      // debugPrint(email);
      // debugPrint(phone);
      final authProvaider = context.read<AuthenticationProvider>();
      fromKey.currentState!.save();
      authProvaider.setLoading(val: true);
      UserCredential? userCredential = await authProvaider.createUserWithEmailAndPassword(
        email:email,
        password: pass,
        onFail: (ErrorMessage) {
          showSnackber(context: context, content: ErrorMessage);
        },

      );
      if(userCredential!=null){
        debugPrint("account has created");
        // account has created successfully
        // now save user data to firestore
        UserModel userModel = UserModel(
          number: phone,
          email: email,
          fname: Fname, 
          uId: userCredential.user!.uid, 
          image: '', 
          createdAt: '',
          sessionKey:" ",
        );
        await authProvaider.saveUserDataToFireStore(
          currentUser: userModel, 
          fileImage: null, 
          onSuccess: (){
            showSnackber(context: context, content: "Account Creation Success.");
            Navigator.pushReplacementNamed(context, Constants.logInScreen);
          }, 
          onFail: (message){
            showSnackber(context: context, content: "$message");
          }
        );
      }
      authProvaider.setLoading(val: false);
    }
    else{
      showSnackber(context: context, content: "please fill the all fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authProvaider = context.watch<AuthenticationProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade500,
              Colors.orange.shade200,
            ],
          ), 
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50,),
            Padding(
              padding: EdgeInsets.all(10), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInUp(duration: Duration(milliseconds: 1000),child: Text("SignUp", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),)),
                  SizedBox(height:10,),
                  FadeInUp(duration: Duration(milliseconds: 1200),child: Text("Welcome Back!",style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),)),
                ],  
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child:FadeInUp(
                duration: Duration(milliseconds: 1400),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                    
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(225, 95, 27, .3),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),                              )
                              ],                  
                            ),
                            child: Form(
                              key: fromKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  
                                  FadeInUp(
                                    duration: Duration(milliseconds: 1600),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                      onChanged: (value){
                                        Fname = value.trim();
                                      },
                                      validator: (value) {
                                        if(Fname.length<4){
                                          return "Name should Contain at least 4 character";
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        label: Text("Full Name"),
                                        border: InputBorder.none,
                                                      
                                      ),
                                    ),
                                    ),
                                  ),
                              
                                  FadeInUp(
                                    duration: Duration(milliseconds: 1600),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                      onChanged: (value){
                                        email = value.trim();
                                      },
                                      validator: (value) {
                                        return emailValidator(value.toString().trim());
                                      },
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        label: Text("Email"),
                                        border: InputBorder.none,
                                                      
                                      ),
                                    ),
                                    ),
                                  ),
                              
                                  FadeInUp(
                                    duration: Duration(milliseconds: 1600),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child:  TextFormField(
                                      onChanged: (value){
                                        phone = value.trim();
                                      },
                                      validator: (value) {
                                        return numberVAladator(value.toString());
                                      },
                                      keyboardType: TextInputType.numberWithOptions(signed: true),
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        label: Text("Phone"),
                                        border: InputBorder.none,
                                        hintText: "Enter Your Phone With Country Code"
                                      ),
                                    ),
                                    ),
                                  ),
                              
                                  FadeInUp(
                                    duration: Duration(milliseconds: 1800),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                        onChanged: (value){
                                          pass = value.trim();
                                        },
                                        validator: (value) {
                                          if(value.toString().contains(" ")){
                                            return "password can't contain SPACE";
                                          }
                                          if(value.toString().length<8){
                                            return "pass should be al least 8 character";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          label: Text("Password",),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          FadeInUp(duration: Duration(milliseconds:2200),
                            child: authProvaider.isLoading?
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: CircularProgressIndicator(),
                              )
                              :
                              SizedBox(
                              width: 200,
                              child: 
                              getButton(label: "Sign Up", ontap: (){
                                signUp();
                                
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>MemberHomeScreen()));
                                },),
                            )
                          
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          FadeInUp(duration:Duration(milliseconds:2400), child: Text("-Or-\nContinue With Socail Media-",textAlign: TextAlign.center,)),
                          SizedBox(
                            height: 30,
                          ),
                          // FadeInUp(
                          //   duration:Duration(milliseconds:2600),
                          //   child:Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     children: [
                          //       getButton(label: "Google", icon: Icon(FontAwesomeIcons.google), ontap:(){}),
                          //       SizedBox(
                          //         width: 20,
                          //       ),
                          //       getButton(label: "Facebook",icon: Icon(Icons.facebook),ontap:(){}),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          FadeInUp(
                            duration:Duration(milliseconds:2800),
                            child: HaveAccountWidget(label: "Don Have An Account? ", acctionText: "SignIn", ontap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return SignInScreen();}));
                          })),
                        ],
                      ),
                    ),
                  )
                ),
              ), 
            ),
          ],
        ),
      ),
    );
  }
}


class HaveAccountWidget extends StatelessWidget {
  const HaveAccountWidget({
    super.key,
    this.label,
    required this.acctionText,
    required this.ontap,
    });

  final String ?label;
  final String acctionText;
  final Function() ontap; 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label??"" , style: TextStyle(color: Colors.blue, fontSize: 20),),
        TextButton(onPressed: ontap, child: Text(acctionText,style: TextStyle(color: Colors.orange, fontSize: 20),),),
      ],
    );
  }
}