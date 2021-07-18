docker run --env-file .env -v "$1:/tmp/deposits.json" kirillfedoseev/eth2-testnet-helper src/deposit.js $2
