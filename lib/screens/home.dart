import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:algorand_dart/algorand_dart.dart';

import '../account.dart';
import '../contracts/approval.teal';
import '../contracts/clear.teal';
import 'liquidity_components/form/liquidity_form.dart';
import 'swap_components/form/swap_form.dart';

import 'package:flutter_algosigner/algosigner.dart';
import 'package:flutter_algosigner/algosigner_web.dart';
import 'package:flutter_algosigner/generated_plugin_registrant.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget form = SwapForm();
  String mode = "swap";
  Acc acc = Acc();


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: shader(
            "Canario Swap",
            TextStyle(fontWeight: FontWeight.bold),
          ),
          
          actions: <Widget>[
            connectButton(),
            SizedBox(width: 20,),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 340,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 40.0,
                          width: size.width * 0.1,
                          child: RaisedButton(
                            onPressed: (){
                              setState(() {
                                mode = "swap";
                                form = SwapForm();
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
                                    colors: mode == "swap" ?
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
                        ),
                        Container(
                          height: 40.0,
                          width: size.width * 0.1,
                          child: RaisedButton(
                            onPressed: (){
                              setState(() {
                                mode = "liquidity";
                                form = LiquidityForm();
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
                                    colors: mode == "liquidity" ?
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
                                  "LIQUIDITY",
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
                        ),
                      ],
                    ),
                    form
                  ],
                ),
              ),
            )
          ],
        ),
      )
      
    );
  }

  Widget shader(String text, TextStyle style) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.green,
          Colors.yellow,
          Colors.green,
        ],
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }

  Widget connectButton() {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 40.0,
      width: size.width * 0.1,
      child: RaisedButton(
        onPressed: () async {
          await AlgoSigner.connect();
          acc.account = await AlgoSigner.accounts(ledger: 'TestNet');
          // declare application state storage (immutable)
          final localInts = 1;
          final localBytes = 1;
          final globalInts = 1;
          final globalBytes = 0;

          final approvalProgram =
              await acc.algorand.applicationManager.compileTEAL(approval.teal);

          final clearProgram =
              await acc.algorand.applicationManager.compileTEAL(clearProgramSource);

          final params = await acc.algorand.getSuggestedTransactionParams();

          final transaction = await (ApplicationCreateTransactionBuilder()
                ..sender = acc.account[0]
                ..approvalProgram = approvalProgram.program
                ..clearStateProgram = clearProgram.program
                ..globalStateSchema = StateSchema(
                  numUint: globalInts,
                  numByteSlice: globalBytes,
                )
                ..localStateSchema = StateSchema(
                  numUint: localInts,
                  numByteSlice: localBytes,
                )
                ..suggestedParams = params)
              .build();

          final signedTx = await transaction.sign(account);
          final txId = await algorand.sendTransaction(
            signedTx,
            waitForConfirmation: true,
          );
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
                ]
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints:
                BoxConstraints(maxWidth: size.width * 0.4, minHeight: 20.0),
            alignment: Alignment.center,
            child: Text(
              "Connect",
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

