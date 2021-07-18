docker run -it -v "$(pwd)/validator_keys:/app/validator_keys" -e GENESIS_FORK_VERSION="$1" kirillfedoseev/eth2-deposit-cli \
  new-mnemonic \
  --chain test \
  --amount 1000000000 \
  --num_validators $2 \
  --mnemonic_language english \
  --keystore_password 12345678
