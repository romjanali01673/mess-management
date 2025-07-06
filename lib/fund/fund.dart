import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/fund/clear_fund.dart';
import 'package:mess_management/fund/fand_list.dart';
import 'package:mess_management/fund/fund_entry.dart';
import 'package:mess_management/helper/helper_method.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/model/fund_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/fund_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/ui_helper/ui_helper.dart';
import 'package:provider/provider.dart';

class FundScreen extends StatefulWidget {
  const FundScreen({super.key});

  @override
  State<FundScreen> createState() => _FundScreenState();
}


class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Optional: background color
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _FundScreenState extends State<FundScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final List<String> tabs =const ['Fund Tnx List', 'Add Fund', 'Clear Fand'];
  final List<Icon> icons =const [Icon(Icons.list_alt),Icon(Icons.create),Icon(Icons.clear),];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context, scrollable){
        return [
          SliverAppBar(
            backgroundColor: Colors.grey,
            title: AnimatedBuilder(
              animation: _tabController!,
              builder: (context, child) {
                return Text(tabs[_tabController!.index]);
              },
            ),
            actions: [],
            floating: true,
            snap: true,
            pinned: true,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,// must assign otherwise get an error
              tabAlignment: TabAlignment.start,
              labelColor: Colors.black,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.black,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              indicatorColor: Colors.black,
              tabs:tabs.map((e)=> Tab(text: e.toString() , icon:icons[tabs.indexOf(e)],)).toList(),
            ),
          ),
          
        ];
      },
      
      body:TabBarView(
        controller: _tabController,
        children: [
          FundList(),
          AddFund(),
          ClearFund(),
        ],
      )
    );
  }
}



