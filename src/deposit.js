const Web3 = require('web3')

const { abi } = require('./artifacts/contract.json')

const { RPC_URL, DEPLOYMENT_PRIVATE_KEY } = process.env

const web3 = new Web3(RPC_URL)
const { address } = web3.eth.accounts.wallet.add(DEPLOYMENT_PRIVATE_KEY)

const depositData = require('/tmp/deposits.json')

async function main() {
  const contract = new web3.eth.Contract(abi, process.argv[2])

  console.log(`Sending ${depositData.length} deposit transactions`)
  let nonce = await web3.eth.getTransactionCount(address)
  for (const deposit of depositData) {
    const receipt = await contract.methods.deposit(
      `0x${deposit.pubkey}`,
      `0x${deposit.withdrawal_credentials}`,
      `0x${deposit.signature}`,
      `0x${deposit.deposit_data_root}`,
    ).send({
      from: address,
      nonce: nonce++,
      gas: 200000
    })
    console.log(receipt.transactionHash)
  }
}

main()
