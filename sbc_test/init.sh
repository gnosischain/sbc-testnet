set -e

source .env

docker context rm bootnode node1 node2 node3 node4 node5 explorer 2>&1 > /dev/null || true
docker context create bootnode --docker host=ssh://root@$IP_BOOTNODE
docker context create node1 --docker host=ssh://root@$IP_NODE1
docker context create node2 --docker host=ssh://root@$IP_NODE2
docker context create node3 --docker host=ssh://root@$IP_NODE3
docker context create node4 --docker host=ssh://root@$IP_NODE4
docker context create node5 --docker host=ssh://root@$IP_NODE5
docker context create explorer --docker host=ssh://root@$IP_EXPLORER

CLEAN='rm -rf ~/sbc_test; mkdir -p ~/sbc_test/config; docker kill $(docker ps -q) 2>&1 > /dev/null || true;'
ssh root@$IP_BOOTNODE "$CLEAN"
ssh root@$IP_NODE1 "$CLEAN"
ssh root@$IP_NODE2 "$CLEAN"
ssh root@$IP_NODE3 "$CLEAN"
ssh root@$IP_NODE4 "$CLEAN"
ssh root@$IP_NODE5 "$CLEAN"
ssh root@$IP_EXPLORER "$CLEAN"

scp ./config.yml ./password.txt ./node1/*.txt root@$IP_NODE1:/root/sbc_test/config
scp ./config.yml ./password.txt ./node2/*.txt root@$IP_NODE2:/root/sbc_test/config
scp ./config.yml ./password.txt ./node3/*.txt root@$IP_NODE3:/root/sbc_test/config
scp ./config.yml ./password.txt ./node4/*.txt root@$IP_NODE4:/root/sbc_test/config
scp ./config.yml ./password.txt ./node5/*.txt root@$IP_NODE5:/root/sbc_test/config
scp ./config.yml ./explorer/* root@$IP_EXPLORER:/root/sbc_test/config

IP_NODE=$IP_NODE1 docker-compose -f docker-compose.node.yml --context node1 run validator-init
IP_NODE=$IP_NODE2 docker-compose -f docker-compose.node.yml --context node2 run validator-init
IP_NODE=$IP_NODE3 docker-compose -f docker-compose.node.yml --context node3 run validator-init
IP_NODE=$IP_NODE4 docker-compose -f docker-compose.node.yml --context node4 run validator-init
IP_NODE=$IP_NODE5 docker-compose -f docker-compose.node.yml --context node5 run validator-init

docker-compose -f docker-compose.explorer.yml --context explorer up -d postgres

IP_NODE=$IP_BOOTNODE docker-compose -f docker-compose.bootnode.yml --context bootnode up -d bootnode

IP_NODE=$IP_NODE1 docker-compose -f docker-compose.node.yml --context node1 up -d node
IP_NODE=$IP_NODE2 docker-compose -f docker-compose.node.yml --context node2 up -d node
IP_NODE=$IP_NODE3 docker-compose -f docker-compose.node.yml --context node3 up -d node
IP_NODE=$IP_NODE4 docker-compose -f docker-compose.node.yml --context node4 up -d node
IP_NODE=$IP_NODE5 docker-compose -f docker-compose.node.yml --context node5 up -d node

IP_NODE=$IP_NODE1 docker-compose -f docker-compose.node.yml --context node1 up -d validator
IP_NODE=$IP_NODE2 docker-compose -f docker-compose.node.yml --context node2 up -d validator
IP_NODE=$IP_NODE3 docker-compose -f docker-compose.node.yml --context node3 up -d validator
IP_NODE=$IP_NODE4 docker-compose -f docker-compose.node.yml --context node4 up -d validator
IP_NODE=$IP_NODE5 docker-compose -f docker-compose.node.yml --context node5 up -d validator

INDEXER_NODE_HOST=$IP_NODE5 docker-compose -f docker-compose.explorer.yml --context explorer up -d explorer