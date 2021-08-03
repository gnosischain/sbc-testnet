docker run -it -v "$(pwd)/validator_keys:/app/validator_keys" kirillfedoseev/eth2-deposit-cli \
  new-mnemonic \
  --chain stake \
  --num_validators $1 \
  --mnemonic_language english \
  --keystore_password 12345678
