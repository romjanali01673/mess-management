import 'package:flutter/material.dart';

class OptimizedNestedSliverList extends StatelessWidget {
  const OptimizedNestedSliverList({super.key});

  final List<Map<String, List<String>>> sections = const [
    {'Section 1': ['Item 1.1', 'Item 1.2']},
    {'Section 2': ['Item 2.1', 'Item 2.2', 'Item 2.3']},
    {'Section 3': ['Item 3.1', 'Item 3.2']},
    {'Section 4': ['Item 4.1', 'Item 4.2', 'Item 4.3']},
    {'Section 5': ['Item 5.1', 'Item 5.2', 'Item 5.3']},
    {'Section 6': ['Item 6.1', 'Item 6.2', 'Item 6.3']},
    {'Section 8': ['Item 7.1', 'Item 7.2', 'Item 7.3']},
    {'Section 9': ['Item 7.1', 'Item 7.2', 'Item 7.3']},
    {'Section 10': ['Item 10.1', 'Item 10.2', 'Item 10.3']},
    {'Section 11': ['Item 11.1', 'Item 11.2', 'Item 11.3']},
    {'Section 12': ['Item 12.1', 'Item 12.2', 'Item 12.3']},
    {'Section 13': ['Item 13.1', 'Item 13.2', 'Item 13.3']},
    {'Section 14': ['Item 14.1', 'Item 14.2', 'Item 14.3']},
    {'Section 15': ['Item 15.1', 'Item 15.2', 'Item 15.3']},
    {'Section 16': ['Item 16.1', 'Item 16.2', 'Item 16.3']},
    {'Section 17': ['Item 17.1', 'Item 17.2', 'Item 17.3']},
    {'Section 18': ['Item 18.1', 'Item 18.2', 'Item 18.3']},
    {'Section 19': ['Item 19.1', 'Item 19.2', 'Item 19.3']},
    {'Section 20': ['Item 20.1', 'Item 20.2', 'Item 20.3']},
    {'Section 21': ['Item 21.1', 'Item 21.2', 'Item 21.3']},
    {'Section 22': ['Item 22.1', 'Item 22.2', 'Item 22.3']},
    {'Section 23': ['Item 23.1', 'Item 23.2', 'Item 23.3']},
    {'Section 24': ['Item 24.1', 'Item 24.2', 'Item 24.3']},
    {'Section 25': ['Item 25.1', 'Item 25.2', 'Item 25.3']},
    {'Section 26': ['Item 26.1', 'Item 26.2', 'Item 26.3']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optimized Lazy Nested List')),
      body: !false? CustomScrollView(
        // in here for multiple list of sliverlist we did not spacify height/expanded that's why we can smothly see one by one as list. and for invisible sliverlist it initially build only one child where listview build many. you will not see pexal issue unlike listview.
        slivers: [
          // Build each section (title + children) as its own sliver group,
          // not lazy
          for (final section in sections) ...[
            // Section title
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade100,
                child: Text(
                  section.keys.first,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Section children (lazy built)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = section.values.first[index];
                  print("Building ${section.keys.first} -> $item");
                  return Card(child: ListTile(title: Text(item)));
                },
                childCount: section.values.first.length,
              ),
            ),

          ]
        ],
      ) 
      :
      SingleChildScrollView(
        child: Column(
          children:
            List.generate(30,(index){
              return
              SizedBox(
                height: 2000,
                child: ListView.builder(
                      // shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context , index2){
                        print("$index.$index2");
                        return Card(child: Text("$index.$index2", style: TextStyle(fontSize: 30),));
                      },
                      itemCount: 1000,
                    ),
              );
            }),
        ),
      )
    );
  }
}
