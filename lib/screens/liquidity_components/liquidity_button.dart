import 'dart:convert';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_algosigner/algosigner.dart';
import 'dart:typed_data';
import '../../account.dart';


import 'package:flutter_myalgo_connect/myalgo_connect.dart';
import 'package:flutter_myalgo_connect/myalgo_connect_web.dart';

class LiquidityButton extends StatefulWidget {
  String option;
  String algoAmount;
  String tokenAmount;
  LiquidityButton({Key? key, required this.option, required this.algoAmount, required this.tokenAmount}) : super(key: key);
  @override
  _LiquidityButtonState createState() => _LiquidityButtonState();
}

class _LiquidityButtonState extends State<LiquidityButton> {
  Acc acc = Acc();
  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 55.0,
      width: size.width * 0.2,
      child: RaisedButton(
        onPressed: () async{
          if(widget.option == "ADD"){
            final params = await acc.algorand.getSuggestedTransactionParams();
          
            final tx1 = await (ApplicationCallTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            // id of the application
            ..applicationId = 70171358
            ..arguments = [Uint8List.fromList("add_liquidity".codeUnits),Uint8List.fromList("69768909".codeUnits)]
            ..suggestedParams = params
            ..foreignAssets = [69768909]
            ..flatFee = 2000
            ).build();
            final tx2 = await (PaymentTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            ..amount = int.parse(widget.algoAmount)
            // this should be the smart contract address
            ..receiver = Address.fromAlgorandAddress(address: "ZBXU7NWTQLFG3TYJ2Z2JRXU57XJJHJWZFNDMNWRE4VCNWAV6M5MUZSLTXQ")
            ..suggestedParams = params
            ..flatFee = 2000
            ).build();
            final tx3 = await (AssetTransferTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            ..amount = int.parse(widget.tokenAmount)
            ..assetId = 69768909
            // this should be the smart contract address (test if the id can be used as well)
            ..receiver = Address.fromAlgorandAddress(address: "ZBXU7NWTQLFG3TYJ2Z2JRXU57XJJHJWZFNDMNWRE4VCNWAV6M5MUZSLTXQ")
            ..suggestedParams = params
            ..flatFee = 2000
            ).build();
            AtomicTransfer.group([tx1, tx2, tx3]);
            
            final txs = await MyAlgoConnect.signTransactions([
              tx1.toBase64(),
              tx2.toBase64(),
              tx3.toBase64(),
            ]);
            final blob1 = txs[0]['blob'];
            final blob2 = txs[1]['blob'];
            final blob3 = txs[2]['blob'];
            
            String txId = "";
            try{
              txId = await acc.algorand.sendRawTransactions([
                base64Decode(blob1),
                base64Decode(blob2),
                base64Decode(blob3)
              ]);
            } on AlgorandException catch (ex){
              final cause = ex.cause;
              if (cause is DioError) {
                print(cause.response?.data['message']);
              }
            }
            final tx = await acc.algorand.waitForConfirmation(txId);
            print('https://testnet.algoexplorer.io/tx/$txId');
          } else {
            final params = await acc.algorand.getSuggestedTransactionParams();
          
            final tx1 = await (ApplicationCallTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            // id of the application
            ..applicationId = 70171358
            ..foreignAssets = [69768909]
            ..arguments = [Uint8List.fromList("remove_liquidity".codeUnits),Uint8List.fromList(widget.algoAmount.codeUnits), Uint8List.fromList("69768909".codeUnits)]
            ..suggestedParams = params
            ).build();
            final txs = await MyAlgoConnect.signTransaction(tx1.toBase64());
            final blob = txs['blob'];
            final txId = await acc.algorand.sendRawTransaction(
              base64Decode(blob),
            );
            final tx = await acc.algorand.waitForConfirmation(txId);
            print('https://testnet.algoexplorer.io/tx/$txId');
          }
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.green,
                  Colors.yellow,
                  Colors.green,
                ],
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints:
                BoxConstraints(maxWidth: size.width * 0.4, minHeight: 20.0),
            alignment: Alignment.center,
            child: Text(
              widget.option + " liquidity",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}