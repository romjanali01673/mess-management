import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_hisab/helper/ui_helper.dart';

class NoticeAndAnnouncementScreen extends StatefulWidget {
  const NoticeAndAnnouncementScreen({super.key});

  @override
  State<NoticeAndAnnouncementScreen> createState() => _NoticeAndAnnouncementScreenState();
}

class _NoticeAndAnnouncementScreenState extends State<NoticeAndAnnouncementScreen> {
  

  @override
  Widget build(BuildContext context) {
    bool show_comment = false;

    return Scaffold(
      body: Container(
        // color: Colors.grey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10,top: 5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    getMenuItems(
                      label: "Members", 
                      ontap: (){
              
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red,
                              ),
                              title: Text("MD ROMJAN ALI"),
                              subtitle: Row(children:[ Text("40m"), Icon(Icons.group)]),
                              trailing: 
                              // Text("data"),
                              Row(
                                    mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(onPressed: (){} , icon: Icon(Icons.more_horiz), iconSize: 30,),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Text("Caption.. askldfksdj l;ksdjf sdfoi l;sdf od\n\su lsjf ds oiaw klsdjf asd; lkjkasjfs klasdf sadj asdf f  ls jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj.......", textAlign: TextAlign.start, style: TextStyle(fontSize: 18),),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text("5.6M"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.thumbsUp),
                                          SizedBox(width: 10,),
                                          Text("Like"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("1.3k"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      onTap: (){show_comment = (!show_comment==true); setState(() {
                                    
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.comment),
                                          SizedBox(width: 10,),
                                          Text("Comment"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("989"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          Icon(Icons.share),
                                          SizedBox(width: 10,),
                                          Text("Share"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            show_comment==true?
                            
                            Divider(
                              thickness: 2,
                              height: 20,
                            ) 
                            :
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red,
                              ),
                              title: Text("MD ROMJAN ALI"),
                              subtitle: Row(children:[ Text("40m"), Icon(Icons.group)]),
                              trailing: 
                              // Text("data"),
                              Row(
                                    mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(onPressed: (){} , icon: Icon(Icons.more_horiz), iconSize: 30,),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Text("Caption.. askldfksdj হেল্ল জানে মন কেমন আছ?  l;ksdjf sdfoi l;sdf od\n\n\n\su lsjf ds oiaw klsdjf asd; lkjkasjfs klasdf sadj asdf f  ls jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj.......", textAlign: TextAlign.start, style: TextStyle(fontSize: 18),),
                            ),
                            Stack(
                              children: [
                                Container(
                                  color: Colors.red,
                                  height: 400,
                                ),
                                            
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Column(
                                    children: [
                                      Text("+5", style: TextStyle(fontSize: 30),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text("5.6M"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.thumbsUp),
                                          SizedBox(width: 10,),
                                          Text("Like"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("1.3k"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      onTap: (){show_comment = (!show_comment==true); setState(() {
                                    
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.comment),
                                          SizedBox(width: 10,),
                                          Text("Comment"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("989"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          Icon(Icons.share),
                                          SizedBox(width: 10,),
                                          Text("Share"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            show_comment==true?
                            
                            Divider(
                              thickness: 2,
                              height: 20,
                            ) 
                            :
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red,
                              ),
                              title: Text("MD ROMJAN ALI"),
                              subtitle: Row(children:[ Text("40m"), Icon(Icons.group)]),
                              trailing: 
                              // Text("data"),
                              Row(
                                    mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(onPressed: (){} , icon: Icon(Icons.more_horiz), iconSize: 30,),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3.0),
                              child: Text("Caption.. askldfksdj l;ksdjf sdfoi l;sdf od\n\n\n\n\n\n\n\n\n\n\nn\n\n\n\n\nn\n\n\n\n\nn\n\n\n\n\nn\n\n\n\n\n\n\n\\n\su lsjf ds oiaw klsdjf asd; lkjkasjfs klasdf sadj asdf f  ls jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj.......", textAlign: TextAlign.start, style: TextStyle(fontSize: 18),),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text("5.6M"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.thumbsUp),
                                          SizedBox(width: 10,),
                                          Text("Like"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("1.3k"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      onTap: (){show_comment = (!show_comment==true); setState(() {
                                    
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.comment),
                                          SizedBox(width: 10,),
                                          Text("Comment"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("989"),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          Icon(Icons.share),
                                          SizedBox(width: 10,),
                                          Text("Share"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            show_comment==true?
                            
                            Divider(
                              thickness: 2,
                              height: 20,
                            ) 
                            :
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      Text("All Done"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}