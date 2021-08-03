const Web3 = require('web3')

const { abi } = require('./artifacts/contract.json')

const { RPC_URL, DEPLOYMENT_PRIVATE_KEY, BATCH_SIZE } = process.env

const web3 = new Web3(RPC_URL)
const { address } = web3.eth.accounts.wallet.add(DEPLOYMENT_PRIVATE_KEY)

const depositData = require('/tmp/deposits.json')

const batchSize = parseInt(BATCH_SIZE, 10)
async function main() {
  const contract = new web3.eth.Contract(abi, process.argv[2])

  console.log(`Sending ${Math.ceil(depositData.length / batchSize)} deposit transactions in batches of ${batchSize} events`)
  let nonce = await web3.eth.getTransactionCount(address)
  let count = 0
  let arr = [[], [], [], []]
  for (const deposit of depositData) {
    arr[0].push(`0x${deposit.pubkey}`)
    arr[1].push(`0x${deposit.withdrawal_credentials}`)
    arr[2].push(`0x${deposit.signature}`)
    arr[3].push(`0x${deposit.deposit_data_root}`)
    count++

    if (count === batchSize) {
      const receipt = await contract.methods.batch_deposit(...arr).send({
        from: address,
        nonce: nonce++,
        gas: 5000000
      })
      console.log(receipt.transactionHash)
      arr = [[], [], [], []]
      count = 0
    }
  }
  if (count > 0) {
    const receipt = await contract.methods.batch_deposit(...arr).send({
      from: address,
      nonce: nonce++,
      gas: 5000000
    })
    console.log(receipt.transactionHash)
  }
}

main()
