import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter_algosigner/algosigner.dart';
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
            ..sender = acc.account[0]
            // id of the application
            ..applicationId = 9999999
            ..arguments = [Uint8List.fromList("algo_to_token".codeUnits),Uint8List.fromList(acc.account[0].toString().codeUnits)]
            ..suggestedParams = params
            ).build();
            final transaction2 = await (PaymentTransactionBuilder()
            ..sender = acc.account[0]
            ..amount = Algo.toMicroAlgos(double.parse(widget.amount))
            // this should be the smart contract address
            ..receiver = Address.fromAlgorandAddress(address: "address")
            ..suggestedParams = params
            ).build();
            AtomicTransfer.group([transaction1, transaction2]);
            final txs = await AlgoSigner.signTransactions([
              {
                'txn': transaction1.toBase64()
              },
              {
                'txn': transaction2.toBase64()
              },
              
            ]);
            
            final blob = txs[0]['blob'];
            final txId = await AlgoSigner.send(ledger: 'TestNet', transaction: blob);
            final tx = await acc.algorand.waitForConfirmation(txId);
          } else if(widget.type == "token_to_algo"){
            final params = await acc.algorand.getSuggestedTransactionParams();
            final transaction1 = await (ApplicationCallTransactionBuilder()
            ..sender = acc.account[0]
            // id of the application
            ..applicationId = 9999999
            ..arguments = [Uint8List.fromList("token_to_algo".codeUnits)]
            ..suggestedParams = params
            ).build();
            final transaction2 = await (AssetTransferTransactionBuilder()
            ..assetSender = acc.account[0]
            ..amount = Algo.toMicroAlgos(double.parse(widget.amount))
            ..assetId = 999999
            // this should be the smart contract address (test if the id can be used as well)
            ..receiver = Address.fromAlgorandAddress(address: "address")
            ..suggestedParams = params
            ).build();
            AtomicTransfer.group([transaction1, transaction2]);
            final txs = await AlgoSigner.signTransactions([
              {
                'txn': transaction1.toBase64()
              },
              {
                'txn': transaction2.toBase64()
              },
              
            ]);
            
            final blob = txs[0]['blob'];
            final txId = await AlgoSigner.send(ledger: 'TestNet', transaction: blob);
            final tx = await acc.algorand.waitForConfirmation(txId);
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