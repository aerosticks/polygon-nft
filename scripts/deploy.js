/** @format */

const hre = require("hardhat");

const main = async () => {
  try {
    const nftContractFactory = await hre.ethers.deployContract("ChainBattles");

    const nftContract = await nftContractFactory.waitForDeployment();

    console.log("Contract deployed to: ", nftContract.target);

    // const CBAttack = await ethers.deployContract(
    //   "CBAttack",
    //   nftContract.target
    // );
    // const cbAttack = await CBAttack.waitForDeployment();
    // console.log("CBAttack deployed at:", cbAttack.target);

    // const CBHeal = await ethers.getContractFactory(
    //   "CBHeal",
    //   nftContract.target
    // );
    // const cbHeal = await CBHeal.waitForDeployment();
    // console.log("CBHeal deployed at:", cbHeal.target);

    // const CBMint = await ethers.getContractFactory(
    //   "CBMint",
    //   nftContract.target
    // );
    // const cbMint = await CBMint.waitForDeployment();
    // console.log("CBMint deployed at:", cbMint.target);

    // const CBRevive = await ethers.getContractFactory(
    //   "CBRevive",
    //   nftContract.target
    // );
    // const cbRevive = await CBRevive.waitForDeployment();
    // console.log("CBRevive deployed at:", cbRevive.target);

    // const CBTrain = await ethers.getContractFactory(
    //   "CBTrain",
    //   nftContract.target
    // );
    // const cbTrain = await CBTrain.waitForDeployment();
    // console.log("CBTrain deployed at:", cbTrain.target);

    const CBAttack = await ethers.getContractFactory("CBAttack");
    const cbAttack = await CBAttack.deploy(nftContract.target);
    await cbAttack.deployed();
    console.log("CBAttack deployed at:", cbAttack.target);

    const CBHeal = await ethers.getContractFactory("CBHeal");
    const cbHeal = await CBHeal.deploy(nftContract.target);
    await cbHeal.deployed();
    console.log("CBHeal deployed at:", cbHeal.target);

    const CBMint = await ethers.getContractFactory("CBMint");
    const cbMint = await CBMint.deploy(nftContract.target);
    await cbMint.deployed();
    console.log("CBMint deployed at:", cbMint.target);

    const CBRevive = await ethers.getContractFactory("CBRevive");
    const cbRevive = await CBRevive.deploy(nftContract.target);
    await cbRevive.deployed();
    console.log("CBRevive deployed at:", cbRevive.target);

    const CBTrain = await ethers.getContractFactory("CBTrain");
    const cbTrain = await CBTrain.deploy(nftContract.target);
    await cbRevive.deployed();
    console.log("CBTrain deployed at:", cbTrain.target);

    await nftContract.setModules(
      cbAttack.target,
      cbMint.target,
      cbRevive.target,
      cbTrain.target,
      cbHeal.target
    );
    console.log(
      "ChainBattles updated with module addresses, main contract address is ",
      nftContract.target
    );

    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

main();
