import 'package:flutter/material.dart';
import 'package:mess_management/helper/ui_helper.dart';

class PaymentInputStyled extends StatefulWidget {
  @override
  _PaymentInputStyledState createState() => _PaymentInputStyledState();
}

class _PaymentInputStyledState extends State<PaymentInputStyled> {
  final TextEditingController _controller = TextEditingController(text: '600');
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: 
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        
      ],
    ),
        ),
      ),
    );
    
    
  }
}
