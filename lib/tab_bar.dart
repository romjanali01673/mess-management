import 'package:flutter/material.dart';

class TabBarScreen extends StatefulWidget {
  const TabBarScreen({super.key});

  @override
  State<TabBarScreen> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        // backgroundColor: Colors.green,
        appBar:PreferredSize(preferredSize: Size(double.infinity, 80), child: 
         AppBar(
          actions: [
            Icon(Icons.kayaking)
          ],
          backgroundColor: Colors.grey,
          bottom: TabBar(
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
              indicatorColor: Colors.black,
              
              
              tabAlignment: TabAlignment.center,
              
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.abc), text: "add",),
                Tab(icon: Icon(Icons.abc), text: " y iuyi i iyi d",),
                Tab(icon: Icon(Icons.abc), text: "add",),
                Tab(icon: Icon(Icons.abc), text: "add",),
                Tab(icon: Icon(Icons.abc), text: "add",),
                Tab(icon: Icon(Icons.abc), text: " y iuyi i iyi d",),
                Tab(icon: Icon(Icons.abc), text: "add",),
                Tab(icon: Icon(Icons.abc), text: "add",),
              ],
            ),
        
        ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // SizedBox(
              //   height: 40,
              // ),
              
              Expanded(
                child: TabBarView(children: [
                  screen1(),
                  screen2(),
                  screen3(),
                  screen4(),
                  screen1(),
                  screen2(),
                  screen3(),
                  screen4(),
                ]),
              ),
            ],
          ),
        ),
      ),
      );
  }
}

class screen1 extends StatelessWidget {
  const screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
        "screen 1"
        ),
      ),
    );
  }
}
class screen2 extends StatelessWidget {
  const screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text(
              "screen 2"
              ),
            ),
            Container(
              color: Colors.red,
              height: 200,
            ),
            Container(
              color: Colors.green,
              height: 200,
            ),
            Container(
              color: Colors.red,
              height: 200,
            ),
            Container(
              color: Colors.green,
              height: 200,
            ),
            Container(
              color: Colors.red,
              height: 200,
            ),
            Container(
              color: Colors.green,
              height: 200,
            ),
            Container(
              color: Colors.red,
              height: 200,
            ),
            Container(
              color: Colors.green,
              height: 200,
            ),
            Container(
              color: Colors.red,
              height: 200,
            ),
            Container(
              color: Colors.green,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}
class screen3 extends StatelessWidget {
  const screen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
        "screen 3"
        ),
      ),
    );
  }
}
class screen4 extends StatelessWidget {
  const screen4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
        "screen 4"
        ),
      ),
    );
  }
}