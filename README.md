# This repo describes the way of running custom ETH2.0 network from scratch

## Step 0
Choose a minimal number of validators to run (e.g. 16). Beacon chain will not start with smaller amount.

Setup env file. Template is in `.env.example`.

Build helper docker image:
```shell
./scripts/build.sh
```

## Step 1
Generate keystore files and deposit data for all validators.

This can be done by running the following:

```shell
./scripts/generate.sh 16
```

This command runs the docker container with the forked version of official [eth2.0-deposit-cli](https://github.com/ethereum/eth2.0-deposit-cli).

First argument is the fork version to run (analogue of eth1 chain id, mainnet uses `00000000`) - 4 hex-encoded bytes without `0x` prefix.
Second argument is the number of validators to generate.

You will see the generated master-key mnemonic. You need to copy and re-enter it once again, then you will finally see the generation process.

After command completion, you can find all artifacts in `./validator_keys/` directory. There will be `N` keystore files and 1 file describing all deposit configurations.

## Step 2
Deploy new deposit contract.

```shell
./scripts/deploy.sh
```

This will deploy and output the deployed contract address in the stdout. You can verify the contract source code manually in etherscan by using the code in `./src/artifacts/Deposit.sol`.

## Step 3
Execute deposits.

```shell
./scripts/deposit.sh $(pwd)/validator_keys/deposit_data-*.json 0x<deposit_contract_data>
```

First argument is the deposit data file generated in Step 1.
Second argument is the address of the deposit contract.

## Step 4
Prepare yaml config for beacon chain. Template can be found in `./beacon/config.template.yml`

Pay attention to the following parameters:
* `MIN_GENESIS_ACTIVE_VALIDATOR_COUNT`
* `MIN_GENESIS_TIME`
* `ETH1_FOLLOW_DISTANCE`
* `DEPOSIT_CHAIN_ID`
* `DEPOSIT_NETWORK_ID`
* `DEPOSIT_CONTRACT_ADDRESS`
* `GENESIS_FORK_VERSION`

Other parameters may be left unchanged.

## Step 5
Get binaries for Prysm client.

```shell
git clone https://github.com/prysmaticlabs/prysm.git

cd prysm

./prysm.sh beacon-chain --download-only
./prysm.sh validator --download-only
```

## Step 6
Run two ETH2.0 beacon nodes:

Replace your own deployment blocks, rpc urls and ENR records.
```shell
# In one shell:
./prysm.sh beacon-chain --force-clear-db \
  --contract-deployment-block 8957245 \
  --http-web3provider https://rinkeby.infura.io/v3/... \
  --bootstrap-node "" \
  --config-file config.yml \
  --chain-config-file config.yml \
  --disable-sync \
  --verbosity debug \
  --datadir ./db1
  
# In other shell (find ENR string in the logs of first node):
./prysm.sh beacon-chain --force-clear-db \
  --contract-deployment-block 8957245 \
  --http-web3provider https://rinkeby.infura.io/v3/... \
  --bootstrap-node "" \
  --config-file config.yml \
  --chain-config-file config.yml \
  --disable-sync \
  --verbosity debug \
  --datadir ./db2 \
  --grpc-gateway-port 3501 \
  --rpc-port 4001 \
  --p2p-udp-port 12001 \
  --p2p-tcp-port 13001 \
  --peer "enr:-LK4QNfE6jyAqGmgltwWON3UGU4XJNBQyHmmDJK_Y0D7V8byCbey11CVTbkM2cYi40QRirmBlbb-o3jdEjSWLDBfx18Bh2F0dG5ldHOIAAAAAAAAAACEZXRoMpAnXvoeEjQSNP__________gmlkgnY0gmlwhMCoHxmJc2VjcDI1NmsxoQLCcyeQHzBlQItaDh2OhE4DLFHCgUrf_L28D1K02He4z4N0Y3CCMsiDdWRwgi7g"

```

Run validator connected to the first node:
```shell
./prysm.sh validator wallet recover
./prysm.sh validator --config-file config.yml --chain-config-file config.yml
```

## Step 7
Verify that both node make some progress in mining blocks:

```shell
curl http://127.0.0.1:3500/eth/v1alpha1/beacon/chainhead
curl http://127.0.0.1:3501/eth/v1alpha1/beacon/chainhead
```
