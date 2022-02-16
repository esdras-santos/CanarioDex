# canarioswap

## WARNING: THIS IS NOT PROODUCTION LEVEL CODE

Canario Swap is DEX (Decentralized Exchange) Uniswap-like built on top of the Algorand blockchain and takes advantage of the benefits of this platform such as fast transaction confirmation and low fees. With Canario Swap you can swap between Algo to Token, Token to Algo and Token to Token. Currently there is only one Token (CNT) to swap so the Token to Token option is not available on the front-end.

Canario Swap application Id: 70171358
Canario Token (CNT) Id: 69768909

Pyteal and Teal code available at `./contracs` directory

## Running

1. Install flutter

2. Clone this repositore

```shell
git clone https://github.com/esdras-santos/CanarioDex
```

3. Inside the repositore type run: 
```shell
flutter run -d web-server
```

4. Now just copy the link on the output  and past it into your chrome browser (in this cada `http://localhost:50682`)

![alt text](https://github.com/esdras-santos/CanarioDex/blob/master/extra_media/running.PNG?raw=true)

## Usage

1. Connect by clicking on the `Connect` button and the `MyAlgo` popup will appear

![alt text](https://github.com/esdras-santos/CanarioDex/blob/master/extra_media/connect.PNG?raw=true)

2. after connect with `MyAlgo` you can start to Swap or Add/Remove liquidity (To Add or Remove liquidity you need to own both tokens of the pair)

![alt text](https://github.com/esdras-santos/CanarioDex/blob/master/extra_media/swap.PNG?raw=true)

![alt text](https://github.com/esdras-santos/CanarioDex/blob/master/extra_media/liquidity.PNG?raw=true)

Right there is 5 Algo and 5 CNT available for swap on the Canaio Swap 

## Future upgrades

Add more Tokens and Fix possible UI and smart contract bugs


Check extra_media