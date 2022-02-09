import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_myalgo_connect/myalgo_connect.dart';
import 'package:flutter_myalgo_connect/myalgo_connect_web.dart';

import '../../account.dart';

class SwapButton extends StatefulWidget {
  String type;
  String amount;

  SwapButton({Key? key, required this.type, required this.amount}) : super(key: key);

  @override
  _SwapButtonState createState() => _SwapButtonState();
}

class _SwapButtonState extends State<SwapButton> {
  Acc acc = Acc();

  @override
  void initState(){
    super.initState();

  }

  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 55.0,
      width: size.width * 0.2,
      child: RaisedButton(
        onPressed: () async {
          if(widget.type == "algo_to_token"){
            final params = await acc.algorand.getSuggestedTransactionParams();
            final transaction1 = await (ApplicationCallTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            // id of the application
            ..applicationId = 70171358
            ..arguments = [Uint8List.fromList("algo_to_token".codeUnits),Uint8List.fromList("69768909".codeUnits)]
            ..foreignAssets = [69768909]
            ..suggestedParams = params
            ..flatFee = 2000
            ).build();
            final transaction2 = await (PaymentTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            ..amount = int.parse(widget.amount)
            // this should be the smart contract address
            ..receiver = Address.fromAlgorandAddress(address: "ZBXU7NWTQLFG3TYJ2Z2JRXU57XJJHJWZFNDMNWRE4VCNWAV6M5MUZSLTXQ")
            ..suggestedParams = params
            ..flatFee = 2000 
            ).build();
            AtomicTransfer.group([transaction1, transaction2]);
            final txs = await MyAlgoConnect.signTransactions([
              transaction1.toBase64(),
              transaction2.toBase64()
            ]);
            final blob1 = txs[0]['blob'];
            final blob2 = txs[1]['blob'];
            String txId = "";
            try{
              txId = await acc.algorand.sendRawTransactions([
                base64Decode(blob1),
                base64Decode(blob2)
              ]);
            } on AlgorandException catch (ex){
              final cause = ex.cause;
              if (cause is DioError) {
                print(cause.response?.data['message']);
              }
            }
            
            final tx = await acc.algorand.waitForConfirmation(txId);
            print('https://testnet.algoexplorer.io/tx/$txId');
          } else if(widget.type == "token_to_algo"){
            final params = await acc.algorand.getSuggestedTransactionParams();
            final transaction1 = await (ApplicationCallTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            // id of the application
            ..applicationId = 70171358
            ..arguments = [Uint8List.fromList("token_to_algo".codeUnits),Uint8List.fromList("69768909".codeUnits)]
            ..foreignAssets = [69768909]
            ..suggestedParams = params
            ..flatFee = 2000
            ).build();
            final transaction2 = await (AssetTransferTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: acc.account[0])
            ..amount = int.parse(widget.amount)
            // this should be the smart contract address
            ..receiver = Address.fromAlgorandAddress(address: "ZBXU7NWTQLFG3TYJ2Z2JRXU57XJJHJWZFNDMNWRE4VCNWAV6M5MUZSLTXQ")
            ..assetId = 69768909
            ..suggestedParams = params
            ..flatFee = 2000 
            ).build();
            AtomicTransfer.group([transaction1, transaction2]);
            List<Map<String,dynamic>> txs = []; 
            try{
              txs = await MyAlgoConnect.signTransactions([
              transaction1.toBase64(),
              transaction2.toBase64()
            ]);
            } on MyAlgoException catch(e){
              print(e.cause);
            }
            
            final blob1 = txs[0]['blob'];
            final blob2 = txs[1]['blob'];
            String txId = "";
            try{
              txId = await acc.algorand.sendRawTransactions([
                base64Decode(blob1),
                base64Decode(blob2)
              ]);
            } on AlgorandException catch (ex){
              final cause = ex.cause;
              if (cause is DioError) {
                print(cause.response?.data['message']);
              }
            }
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
              "SWAP",
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