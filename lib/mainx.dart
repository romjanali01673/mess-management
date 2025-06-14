import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DraggableFabScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DraggableFabScreen extends StatefulWidget {
  @override
  _DraggableFabScreenState createState() => _DraggableFabScreenState();
}

class _DraggableFabScreenState extends State<DraggableFabScreen> {
  double posX = 0;
  double posY = 0;

  @override
  void initState() {
    super.initState();
    // Delay getting screen size until layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        posX = (size.width - 56) / 2; // Center horizontally (56 = FAB size)
        posY = size.height - 200; // Near bottom (adjust for AppBar & padding)
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Draggable FAB')),
      body: Stack(
        children: [
          Center(child: Text("Drag the button anywhere!")),

          // Draggable FloatingActionButton
          Positioned(
            left: posX,
            top: posY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  posX += details.delta.dx;
                  posY += details.delta.dy;
                });
              },
              child: FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('FAB tapped')),
                  );
                },
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
