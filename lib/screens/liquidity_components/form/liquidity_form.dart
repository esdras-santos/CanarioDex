import 'package:canarioswap/screens/liquidity_components/liquidity_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../account.dart';

class LiquidityForm extends StatefulWidget {
  
  @override
  _LiquidityFormState createState() => _LiquidityFormState();
}

class _LiquidityFormState extends State<LiquidityForm> {
  String coin1 = "images/algologo.png";
  String coin2 = "images/canary.jpg";
  String coin1name = "ALGO";
  String coin2name = "CNT";
  bool swaporder = false;
  var amountController = TextEditingController();
  String algoAmount = "0.0";
  String tokenAmount = "0.0";
  int algo_reserve = 0;
  int token_reserve = 0;
  Acc acc = Acc();
  String mode = "add";

  int tokenLiquidityAmount(int amount, int input_reserve, int output_reserve){
    if(input_reserve == 0){
      return (amount+1);
    }
    return (amount * output_reserve ~/ input_reserve + 1);
  }

  @override
  void initState(){
    super.initState();
    acc.algorand.getAccountByAddress("NECNUFO5WGOKJ2VFWYA7ITZY5SJJK6LAJZ6YMEDEHB2XOGT6E3XMD5I55A").then((value) {
      algo_reserve = value.amount - 200000;
      token_reserve = value.assets[0].amount;
    });
    
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
                Container(
                  height: 30.0,
                  width: size.width * 0.1,
                  child: RaisedButton(
                    onPressed: (){
                      setState(() {
                        mode = "add";
                      });
                    },
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: mode == "add" ?
                            [
                              Colors.green,
                              Colors.yellow,
                              Colors.green,
                            ] : [
                              Colors.grey,
                              Colors.blueGrey
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: size.width * 0.4, minHeight: 20.0),
                        alignment: Alignment.center,
                        child: Text(
                          "ADD",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30.0,
                  width: size.width * 0.1,
                  child: RaisedButton(
                    onPressed: (){
                      setState(() {
                        mode = "remove";
                      });
                    },
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: mode == "remove" ?
                            [
                              Colors.green,
                              Colors.yellow,
                              Colors.green,
                            ] : [
                              Colors.grey,
                              Colors.blueGrey
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: size.width * 0.4, minHeight: 20.0),
                        alignment: Alignment.center,
                        child: Text(
                          "REMOVE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                        CurrencyTextInputFormatter(maxInputValue: 10000000),
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
                          if(value.contains('.')){
                            var str = value.split('.');
                            print(int.parse(str.join()));
                            algoAmount = str.join();
                          }else{
                            algoAmount = value;
                          }
                          
                          // this input values must be taken from the blockchain
                          tokenAmount = "${tokenLiquidityAmount(int.parse(algoAmount), token_reserve, algo_reserve)}";
                          print(tokenAmount);
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
            mode == "add" ? Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: 300,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[200],
              ),      
              child:  Row(
                children: [
                  Container(
                    width: 220,
                    padding: const EdgeInsets.all(8.0),
                    // this text information need to be taken from the amm front-end function with blockchain data
                    child: Text(
                      tokenAmount,
                      style: TextStyle(fontSize: 18),),
                  ),
                  Container(
                    width: 40,
                    child: Text(coin2name, style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ) ,
            ) : Container(),
            mode == "add" ? LiquidityButton(option: "ADD", algoAmount: algoAmount, tokenAmount: tokenAmount,) : LiquidityButton(option: "REMOVE", algoAmount: algoAmount, tokenAmount: tokenAmount,),
            
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