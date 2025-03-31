#!/bin/bash

source ../.env

forge create --broadcast \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --chain-id $CHAIN_ID \
  src/SecretVote.sol:SecretVote \
  --verify

