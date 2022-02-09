import 'package:algorand_dart/algorand_dart.dart';

class Acc{

  Acc._privateConstructor();
  static final Acc _acc = Acc._privateConstructor();
  factory Acc(){
    return _acc;
  }

  final algodClient = AlgodClient(
      apiUrl: "https://testnet-algorand.api.purestake.io/ps2",
      apiKey: "PfnqW3Fhko5otXC7SDrah89enw41gNSO2kBeMNw0",
      tokenKey: PureStake.API_TOKEN_HEADER
  );

  final algorand = Algorand(
    algodClient: AlgodClient(
      apiUrl: "https://testnet-algorand.api.purestake.io/ps2",
      apiKey: "PfnqW3Fhko5otXC7SDrah89enw41gNSO2kBeMNw0",
      tokenKey: PureStake.API_TOKEN_HEADER
    ),
    indexerClient: IndexerClient(
      apiUrl: "https://testnet-algorand.api.purestake.io/idx2",
      apiKey: "PfnqW3Fhko5otXC7SDrah89enw41gNSO2kBeMNw0",
      tokenKey: PureStake.API_TOKEN_HEADER
    ),
    kmdClient: KmdClient(
      apiUrl: '127.0.0.1',
      apiKey: "PfnqW3Fhko5otXC7SDrah89enw41gNSO2kBeMNw0"
    )
  );

  List<String> account = [];
}