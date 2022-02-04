

require("dotenv").config()
const API_URL = process.env.API_URL
const PUBLIC_KEY = process.env.PUBLIC_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY

async function swap() {
    const { createAlchemyWeb3 } = require("@alch/alchemy-web3")
    const web3 = createAlchemyWeb3(API_URL, {})

    const contract = require("../../artifacts/contracts/Swapper.sol/Swapper.json")
    const contractAddress = "0x1B23bb2F88E043C5C358672A855b74d97331B741"
    const nftContract = new web3.eth.Contract(contract.abi, contractAddress)

    const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest") //get latest nonce

    const tx = {
        from: PUBLIC_KEY,
        to: contractAddress,
        nonce: nonce,
        gas: 7000000,
        data: nftContract.methods.swap(10).encodeABI(),
    }

    const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY)
    signPromise
    .then((signedTx) => {
        web3.eth.sendSignedTransaction(
        signedTx.rawTransaction,
        function (err, hash) {
            if (!err) {
            console.log(
                "The hash of your transaction is: ",
                hash,
                "\nCheck Alchemy's Mempool to view the status of your transaction!"
            )
            } else {
            console.log(
                "Something went wrong when submitting your transaction:",
                err
            )
            }
        }
        ).on('receipt', console.log)
    })
    .catch((err) => {
        console.log("Promise failed:", err)
    })
}
swap();