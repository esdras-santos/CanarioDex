#!/usr/bin/env python3

from algosdk import *
from pyteal import *
import exchange

# Account details (add your mnemonic here)
mn = """"""
try:
    pk = mnemonic.to_public_key(mn)  # Public Key
    sk = mnemonic.to_private_key(mn) # Secret Key
except error.WrongMnemonicLengthError:
    quit(f"Invalid mnemonic. Please update your mnemonic before running.")

# Connect to an algod node. (use a node of your choice here)
algod_token  = "PfnqW3Fhko5otXC7SDrah89enw41gNSO2kBeMNw0" # Algod API Key
algod_addr   = 'https://testnet-algorand.api.purestake.io/ps2' # Algod Node Address
algod_header = {
    'User-Agent': 'Minimal-PyTeal-SDK-Demo/0.1',
    'X-API-Key': algod_token
}
algod_client = v2client.algod.AlgodClient(
    algod_token,
    algod_addr,
    algod_header
)
try:
    algod_client.status()
except error.AlgodHTTPError:
    quit(f"algod node connection failure. Check the host and API key are correct.")

# Define our Approval Contract.
# def approval_contract():
#     return Return(Int(1))

# Define our ClearState Program.
# def clearstate_contract():
#     return Return(Int(1))

# Prepare our contract for sending to the network.
# First convert the PyTeal to TEAL
approval_teal   = compileTeal(exchange.approval(), Mode.Application, version=5)
clearstate_teal = compileTeal(exchange.clear(), Mode.Application, version=5)
# Next compile our TEAL to bytecode. (it's returned in base64)
approval_b64   = algod_client.compile(approval_teal)['result']
clearstate_b64 = algod_client.compile(clearstate_teal)['result']
# Lastly decode the base64.
approval_prog   = encoding.base64.b64decode(approval_b64)
clearstate_prog = encoding.base64.b64decode(clearstate_b64)

# Create a transaction to deploy the contract
# Obtain the current network suggested parameters.
sp = algod_client.suggested_params()
sp.flat_fee = True
sp.fee = 2_000
# Create an application call transaction without an application ID (aka Create)
# txn = future.transaction.ApplicationCreateTxn(
#     pk,
#     sp,
#     future.transaction.OnComplete.NoOpOC,
#     approval_prog,
#     clearstate_prog,
#     future.transaction.StateSchema(5, 10),
#     future.transaction.StateSchema(5, 10)
# )

# txn = future.transaction.AssetCreateTxn(
#     pk,
#     sp,
#     20000000,
#     6,
#     False,
#     asset_name="CNT",
#     manager="272OQEA5MF5PBVYUVJXLSZWNW35YVKRAQDF4RA2AMER4564GEZPX7RORBE",
#     reserve="272OQEA5MF5PBVYUVJXLSZWNW35YVKRAQDF4RA2AMER4564GEZPX7RORBE",
#     freeze="272OQEA5MF5PBVYUVJXLSZWNW35YVKRAQDF4RA2AMER4564GEZPX7RORBE",
#     clawback="272OQEA5MF5PBVYUVJXLSZWNW35YVKRAQDF4RA2AMER4564GEZPX7RORBE"
# )


# txn = future.transaction.ApplicationCallTxn(
#     pk,
#     sp,
#     70171358,
#     on_complete=None,
#     app_args=[str.encode("create_pool")],
#     foreign_assets=[69768909],
# )

# txn = future.transaction.ApplicationOptInTxn(
#     pk,
#     sp,
#     70171358
# )

# txn = future.transaction.AssetOptInTxn(
#     pk,
#     sp,
#     69768909
# )

txn1 = future.transaction.ApplicationCallTxn(
    pk,
    sp,
    70171358,
    None,
    app_args=[str.encode("add_liquidity"), str.encode("69768909")],
    foreign_assets=[69768909]
)

# txn2 = future.transaction.PaymentTxn(
#     pk,
#     sp,
#     "NECNUFO5WGOKJ2VFWYA7ITZY5SJJK6LAJZ6YMEDEHB2XOGT6E3XMD5I55A",
#     1000000,
# )

# txn2 = future.transaction.PaymentTxn(
#     pk,
#     sp,
#     "KR6WSX3ZUVRF26VHH3GQ2ZQTSFJKWUOHOQA2KXQ73QIA4YNYBPNBB3KOAY",
#     1000000
# )

txn2 = future.transaction.PaymentTxn(
    pk,
    sp,
    "ZBXU7NWTQLFG3TYJ2Z2JRXU57XJJHJWZFNDMNWRE4VCNWAV6M5MUZSLTXQ",
    5000000
)

txn3 = future.transaction.AssetTransferTxn(
    pk,
    sp,
    "ZBXU7NWTQLFG3TYJ2Z2JRXU57XJJHJWZFNDMNWRE4VCNWAV6M5MUZSLTXQ",
    5000000,
    69768909
)

# atomic txn
gid = future.transaction.calculate_group_id([txn1,txn2,txn3])
txn1.group = gid
txn2.group = gid
txn3.group = gid

stxn1 = txn1.sign(sk)
stxn2 = txn2.sign(sk)
stxn3 = txn3.sign(sk)

signed_group = [stxn1,stxn2,stxn3]


# Sign and send the transaction to the node!
print(f"Deploying application...")
# txid = algod_client.send_transaction(txn.sign(sk))
txid = algod_client.send_transactions(signed_group)
future.transaction.wait_for_confirmation(algod_client, txid)
print(f"Application deployed with transaction: {txid}")
print(f"https://goalseeker.purestake.io/algorand/testnet/transaction/{txid}")
print(f"https://testnet.algoexplorer.io/tx/{txid}")