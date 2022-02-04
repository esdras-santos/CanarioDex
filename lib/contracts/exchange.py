import os
from pyteal import *

# WARNING: THIS IS NOT PROODUCTION LEVEL CODE
def approval():
    
    TOKEN = Bytes("token")
    LIQUIDITY = Bytes("liquidity")
    RESERVE = Bytes("reserve")
    BALANCE = Bytes("balanceOf")

    @Subroutine(TealType.uint64)
    def amm(amount, input_reserve, output_reserve):
        input_amount_with_fee = amount * Int(997)
        numerator = input_amount_with_fee * output_reserve
        denominator = (input_reserve * Int(1000)) + input_amount_with_fee
        return numerator / denominator

    @Subroutine(TealType.uint64)
    def add_liquidity():
        lkey = Concat(
            LIQUIDITY, Itob(Gtxn[2].xfer_asset())
        )
        rkey = Concat(
            RESERVE, Itob(Gtxn[2].xfer_asset())
        )
        total_liquidity = App.globalGet(lkey)
        
        if(total_liquidity > Int(0)):
            # this line bellow can generate error with the contract balance
            algo_reserve = App.globalGet(rkey)
            token_reserve = AssetHolding.balance(Global.current_application_address(), Gtxn[2].xfer_asset())
            
            liquidity_minted = Gtxn[1].amount() * total_liquidity / algo_reserve
            
            return Seq([
                token_reserve,
                Assert(
                    And(
                        Gtxn[1].amount() > Int(0),
                        Gtxn[2].asset_amount() >= (Gtxn[1].amount() * token_reserve.value() / algo_reserve + Int(1)),
                        liquidity_minted >= Gtxn[0].amount()
                    ),
                ),
                App.globalPut(rkey, algo_reserve + Gtxn[1].amount()),
                App.localPut(Gtxn[0].sender(), BALANCE, App.localGet(Gtxn[0].sender(),BALANCE) + liquidity_minted),
                App.globalPut(lkey, total_liquidity + liquidity_minted),
                liquidity_minted
            ])
        else:
            initial_liquidity = Balance(Global.current_application_address())
            return Seq([
                App.globalPut(rkey, Gtxn[1].amount()),
                App.globalPut(lkey, initial_liquidity),
                App.localPut(Gtxn[0].sender() , BALANCE, initial_liquidity),
                initial_liquidity
            ])

    # receive "amountToRemove"
    # receive an application call
    @Subroutine(TealType.uint64)
    def remove_liquidity():
        lkey = Concat(
            LIQUIDITY, Gtxn[0].application_args[2]
        )
        rkey = Concat(
            RESERVE, Gtxn[0].application_args[2]
        )
        algo_reserve = App.globalGet(rkey)
        token_reserve = AssetHolding.balance(Global.current_application_address(),Btoi(Gtxn[0].application_args[2]))
        total_liquidity = App.globalGet(lkey)
        # args[1] = amountToRemove
        algo_amount = Btoi(Gtxn[0].application_args[1]) * algo_reserve / total_liquidity
        
        return Seq([
            token_reserve,
        
            Assert(
                And(
                    total_liquidity > Int(0),
                )
            ),
            App.localPut(Gtxn[0].sender(),BALANCE, (App.localGet(Gtxn[0].sender(),BALANCE) - Btoi(Gtxn[0].application_args[1]))),
            App.globalPut(lkey, total_liquidity - Btoi(Gtxn[0].application_args[1])),
            App.globalPut(rkey, algo_reserve - algo_amount),
            InnerTxnBuilder.Begin(),
            InnerTxnBuilder.SetFields({
                TxnField.type_enum: TxnType.Payment,
                TxnField.amount: algo_amount,
                TxnField.receiver: Gtxn[0].sender()
            }),
            InnerTxnBuilder.Next(),
            InnerTxnBuilder.SetFields({
                TxnField.type_enum: TxnType.AssetTransfer,
                TxnField.asset_amount: Btoi(Gtxn[0].application_args[1]) * token_reserve.value() / total_liquidity,
                TxnField.xfer_asset: Btoi(Gtxn[0].application_args[2]),
                TxnField.asset_receiver: Gtxn[0].sender()
            }),
            InnerTxnBuilder.Submit(),
            Approve()
        ])
    
    @Subroutine(TealType.uint64)
    def swap_token_to_algo():
        rkey = Concat(
            RESERVE, Itob(Gtxn[1].xfer_asset())
        )
        token_reserve = AssetHolding.balance(Global.current_application_address(), Gtxn[1].xfer_asset())
        algo_reserve = App.globalGet(rkey)
        amount = amm(Gtxn[1].asset_amount(), algo_reserve, token_reserve.value())
        return Seq(  
            token_reserve,
            Assert(
                And(
                    Global.group_size() == Int(2),
                    Gtxn[1].asset_amount() > Int(0),
                )
            ),
            App.globalPut(rkey, algo_reserve - amount),
            InnerTxnBuilder.Begin(),
            InnerTxnBuilder.SetFields({
                TxnField.type_enum: TxnType.Payment,
                TxnField.amount: amount,
                TxnField.receiver: Gtxn[1].sender()
            }),
            InnerTxnBuilder.Submit(),
            Approve()
        )
    
    @Subroutine(TealType.uint64)
    def swap_algo_to_token():
        rkey = Concat(
            RESERVE, Gtxn[0].application_args[1]
        )
        token_reserve = AssetHolding.balance(Global.current_application_address(), Btoi(Gtxn[0].application_args[1]))
        algo_reserve = App.globalGet(rkey)
        return Seq([
            token_reserve,
            Assert(
                And(
                    Global.group_size() == Int(2),
                    Gtxn[1].amount() > Int(0),
                )
            ),
            App.globalPut(rkey, algo_reserve + Gtxn[1].amount()),
            InnerTxnBuilder.Begin(),
            InnerTxnBuilder.SetFields({
                TxnField.type_enum: TxnType.AssetTransfer,
                
                TxnField.amount: amm(Gtxn[1].amount(),(algo_reserve - Gtxn[1].amount()), token_reserve.value()),
                TxnField.xfer_asset: Btoi(Gtxn[0].application_args[1]),
                
                TxnField.receiver: Gtxn[0].sender()
            }),
            InnerTxnBuilder.Submit(),
            Approve()
        ])

    @Subroutine(TealType.uint64)
    def swap_token_to_token():
        rkey = Concat(
            RESERVE, Itob(Gtxn[1].xfer_asset())
        )
        token_reserve = AssetHolding.balance(Global.current_application_address(), Gtxn[1].xfer_asset())
        token_reserve2 = AssetHolding.balance(Global.current_application_address(), Btoi(Gtxn[0].application_args[1]))
        return Seq([
            token_reserve,
            token_reserve2,
            Assert(
                And(
                    Global.group_size() == Int(1),
                    Gtxn[0].accounts.length() == Int(1),
                    Gtxn[1].asset_amount() > Int(0),
                ),
            ),
            InnerTxnBuilder.Begin(),
            
            InnerTxnBuilder.SetFields({
                TxnField.type_enum: TxnType.AssetTransfer,
                TxnField.amount: amm(Gtxn[1].asset_amount(), token_reserve.value(), token_reserve2.value()),
                TxnField.xfer_asset: Btoi(Gtxn[0].application_args[1]),
                TxnField.receiver: Gtxn[1].sender()
            }),
            InnerTxnBuilder.Submit(),
            Approve()
        ])


    @Subroutine(TealType.uint64)
    def create_pool_token():
        
        return Seq(
            InnerTxnBuilder.Begin(),
            InnerTxnBuilder.SetFields(
                {
                    TxnField.type_enum: TxnType.AssetTransfer,
                    TxnField.xfer_asset: Btoi(Gtxn[0].application_args[1]),
                    TxnField.asset_amount: Int(0),
                    TxnField.asset_receiver: Global.current_application_address(),
                }
            ),
            InnerTxnBuilder.Submit(),
            Int(1)
        )

    

    router = Cond(
        [Gtxn[0].application_args[0] == Bytes("token_to_algo"), swap_token_to_algo()],
        [Gtxn[0].application_args[0] == Bytes("algo_to_token"), swap_algo_to_token()],
        [Gtxn[0].application_args[0] == Bytes("token_to_token"), swap_token_to_token()],
        [Gtxn[0].application_args[0] == Bytes("remove_liquidity"), remove_liquidity()],
        [Gtxn[0].application_args[0] == Bytes("add_liquidity"), add_liquidity()],
        [Gtxn[0].application_args[0] == Bytes("create_pool"), create_pool_token()],
    )

    return Cond(
        [Gtxn[0].application_id() == Int(0), Int(1)],
        [Gtxn[0].on_completion() == OnComplete.CloseOut, Int(1)],
        [Gtxn[0].on_completion() == OnComplete.OptIn, Int(0)],
        [Gtxn[0].on_completion() == OnComplete.NoOp, router],
    )


def clear():
    return Return(Int(1))


if __name__ == "__main__":
    path = os.path.dirname(os.path.abspath(__file__))

    with open(os.path.join(path, "approval.teal"), "w") as f:
        f.write(compileTeal(approval(), mode=Mode.Application, version=6))

    with open(os.path.join(path, "clear.teal"), "w") as f:
        f.write(compileTeal(clear(), mode=Mode.Application, version=6))