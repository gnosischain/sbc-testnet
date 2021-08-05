# Launching new beacon chain with block explorer

## Create docker network
1. Run `docker network create sbc --subnet 192.168.144.0/24`
2. If you want to use another subnet, modify `--peer` flag value and designated ip addresses in the docker-compose file. 

## Deploy contract
1. Modify `./.env` file with contains eth1 interaction parameters.
2. Run `./scripts/deploy.sh`.
3. Deployed contract address is printed to the console.

## Modify config (at least DEPOSIT_CONTRACT_ADDRESS)
1. Modify config at `./sbc_test/config.yml` and `./sbc_test/explorer/config.yml`.

## (Optional) generate new set of private keys
1. Run `./scripts/generate.sh 2048` where 2048 is the number of keys to generate.
2. Save mnemonic to `./sbc_test/mnemonic.txt`.
3. Save generate `./validator_keys/deposit_data-*.json` to `./sbc_test/`. You can remove existing deposit data file there.

## Import mnemonic
1. Run `cd ./sbc_test`
2. Run `docker-compose up validator-init`
3. Run `docker-compose up validator-list` and make sure first pubkey is equal to first pubkey in the `./sbc_test/deposit_data-*.json` file.
If not, make sure mnemonic is correct and is saved to the `./sbc_test/mnemonic.txt` without new line at the end.

## Make deposits
1. Run `./scripts/deposit.sh $(pwd)/sbc_test/deposit_data-XXX.json 0x<contract address from step 1>`

## Run node1
1. Run `cd ./sbc_test`
2. Run `docker-compose up -d node1`
3. Wait until it sees all the deposits.
4. You should also see exact future genesis time in the logs.

## Run node2
1. Run `cd ./sbc_test`
2. Run `docker-compose up -d node2`
3. Node should connect to `node1`, you can monitor it in the logs.

## Run validator
1. Run `cd ./sbc_test`
2. Run `docker-compose up -d validator`
3. Validator should connect to node1.
4. Monitor the logs until genesis starts.
5. Validator should sign blocks and propose them, without any errors in the console.
6. Nodes should exchange blocks between them and finalize them overtime.

## Run explorer
1. Modify genesis time in `./sbc_test/explorer/config.yml` to the one seen in the node1/node2 logs.
2. Modify other parameters in config, if necessary.
3. Run `cd ./sbc_test` 
4. Run `docker-compose up -d postgres`. Wait a minute until it starts and create necessary tables.
5. Run `docker-compose up -d explorer`.
6. Go to `localhost:3333` to see the explorer page.
