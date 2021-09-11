const Web3 = require('web3')

const { abi, bytecode } = require('./artifacts/contract.json')

const { RPC_URL, DEPLOYMENT_PRIVATE_KEY } = process.env

const web3 = new Web3(RPC_URL)
const { address } = web3.eth.accounts.wallet.add(DEPLOYMENT_PRIVATE_KEY)

async function main() {
  const contract = new web3.eth.Contract(abi)

  const newContract = await contract.deploy({
    data: bytecode,
    arguments: []
  }).send({
    from: address,
    gas: 5000000
  }).on('receipt', (receipt) => console.log(receipt.blockNumber))

  console.log(newContract.options.address)
}

main()
