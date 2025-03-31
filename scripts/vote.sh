#!/bin/bash

source ../.env

# Replace with your deployed contract address
CONTRACT_ADDRESS=0xB1C9B97E2301EB233cc127a3CD517476BD1BAcD8

# Encrypted vote (use hash of "yes" as example)
ENCRYPTED_VOTE=$(cast keccak "yes")

# Send transaction
cast send $CONTRACT_ADDRESS \
  "submitEncryptedVote(bytes32)" $ENCRYPTED_VOTE \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --chain-id $CHAIN_ID

