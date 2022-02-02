import 'package:canarioswap/screens/swap_components/swap_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:decimal/decimal.dart';
// import '../../../decision_button.dart';
// import '../../../price_input_container.dart';
// import '../../../sell_rounded_button.dart';

class SwapForm extends StatefulWidget {
  
  @override
  _SwapFormState createState() => _SwapFormState();
}

class _SwapFormState extends State<SwapForm> {
  String coin1 = "images/algologo.png";
  String coin2 = "images/canary.jpg";
  String coin1name = "ALGO";
  String coin2name = "CNT";
  bool swaporder = false;
  var amountController = TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
            spreadRadius: 0.0,
            offset: Offset(5.0, 5.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Container(
        height: 350,
        width: 340,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: 20,),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(coin1),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Ink(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Swap order',
                    onPressed: () {
                      setState(() {
                        swaporder = !swaporder;
                        if(swaporder == false){
                          coin1 = "images/algologo.png";
                          coin2 = "images/canary.jpg";
                          coin1name = "ALGO";
                          coin2name = "CNT";
                        }else{
                          coin1 = "images/canary.jpg";
                          coin2 = "images/algologo.png";
                          coin1name = "CNT";
                          coin2name = "ALGO";
                        }
                      });
                    },
                  ),
                ),
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(coin2),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(width: 20,),
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left:8.0),
                    width: 220,
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      controller: amountController,
                      // keyboardType: TextInputType.number,
                      inputFormatters: [
                        CurrencyTextInputFormatter(maxInputValue: 8.0),
                      ],
                      cursorColor: Colors.green,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 20),
                        hintStyle: TextStyle(fontSize: 20),
                        hintText: "0.0",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState((){

                        });
                      },
                    ),
                  ),
                  Container(
                    width: 40,
                    child: Text(coin1name, style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: 300,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[200],
              ),      
              child: Row(
                children: [
                  Container(
                    width: 220,
                    padding: const EdgeInsets.all(8.0),
                    // this text information need to be taken from the amm front-end function with blockchain data
                    child: Text(
                      "0.0",
                      style: TextStyle(fontSize: 20),),
                  ),
                  Container(
                    width: 40,
                    child: Text(coin2name, style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            SwapButton(),
            
          ],
        ),
      ),
    );
  }
}

class CurrencyTextInputFormatter extends TextInputFormatter{
  final double maxInputValue;

  CurrencyTextInputFormatter({required this.maxInputValue});
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final regEx = RegExp(r'^\d*\.?\d*');
    String newString = regEx.stringMatch(newValue.text) ?? '';
    
    if(maxInputValue != null){
      if(double.tryParse(newValue.text) == null){
        return TextEditingValue(
          text: newString,
          selection: newValue.selection,
        );
      }
      if(double.tryParse(newValue.text)! > maxInputValue){
        newString = maxInputValue.toString();
      }
    }
    return TextEditingValue(
      text: newString,
      selection: newValue.selection
    );
  }

}