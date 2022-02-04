async function main() {
    const Contract = await ethers.getContractFactory("Shorter")

    // Start deployment, returning a promise that resolves to a contract object
    const contract = await Contract.deploy()
    await contract.deployed()
    console.log("Contract deployed to address:", contract.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
