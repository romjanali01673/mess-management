import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/authantication/Sign_up.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/helper/helper_method.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<FormState> FormKey = GlobalKey<FormState>();

  String pass = "";
  String email = "";

  

  void signIn()async{
    
    if(FormKey.currentState!.validate()){
      FormKey.currentState!.save();
      final AuthenticationProvider authProvaider = context.read<AuthenticationProvider>();
      print(authProvaider.userModel!.sessionKey);
      authProvaider.setLoading(val: true);
      UserCredential? userCredential = await authProvaider.signInWithEmailAndPassword(
        email: email, 
        password: pass, 
        onFail: (message){
          showSnackber(context: context, content: message);
          authProvaider.setLoading(val: false);
        },
      );
      if(userCredential!=null){
        //user valid, now try to fatch user data
        bool isSuccess = false;
        // get
        await authProvaider.setSessionKey(
          onSuccess: (){
            isSuccess = true;
          },
          onFail: (message){
            isSuccess =false;
            showSnackber(context: context, content: "User Data fatch Error");
          }
        );
        if(isSuccess){
          isSuccess = await authProvaider.getUserProfileData(onFail: (message){
            showSnackber(context: context, content: "somthing Wrong\n try again!");
          });
        }

        
        if(isSuccess){
        // get user data, 
          isSuccess = await authProvaider.saveUserDataToSharedPref();
        }

        if(isSuccess){
        
          // now try to save user data to local store
          await authProvaider.setSignedIn(val: true);
          showSnackber(context: context, content: "Sign In Success");
          Navigator.pushReplacementNamed(context, Constants.LandingScreen);
        }
        
      
      }
      else{
        showSnackber(context: context, content: "Data Not Found In DataBase! \nplease try again.");
      }
      authProvaider.setLoading(val: false);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50,),
            Padding(
              padding: EdgeInsets.all(10), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(duration: Duration(milliseconds: 1000),child: Text("SignIn", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),)),
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
                              key: FormKey,
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
                            child: !authProvaider.isLoading? SizedBox(
                              width: 200,
                              child: getButton(label: "Sign In", ontap: (){
                                signIn();
                                
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>MemberHomeScreen()));
                                },
                              )
                            )
                            :
                              Container(
                            
                                child: CircularProgressIndicator(),
                              )
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          // FadeInUp(duration:Duration(milliseconds:2400), child: Text("-Or-\nContinue With Socail Media-",textAlign: TextAlign.center,)),
                          // SizedBox(
                          //   height: 30,
                          // ),
                          // FadeInUp(
                          //   duration:Duration(milliseconds:2600),
                          //   child:Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     children: [
                          //       getButton(label: "Facebook",icon: Icon(Icons.facebook),ontap:(){}),
                          //       SizedBox(
                          //         width: 20,
                          //       ),
                          //       getButton(label: "Github", icon: Icon(Icons.facebook_outlined), ontap:(){}),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          FadeInUp(duration:Duration(milliseconds:2800),child: HaveAccountWidget(label: "Don't Have An Account? ", acctionText: "SignUp", ontap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return SignUpScreen();}));
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
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label??"" , style: TextStyle(color: Colors.blue, fontSize: 20),),
        TextButton(onPressed: ontap, child: Text(acctionText,style: TextStyle(color: Colors.orange, fontSize: 20),),),
      ],
    );
  }
}

