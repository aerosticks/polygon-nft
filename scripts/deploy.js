/** @format */

const hre = require("hardhat");

const main = async () => {
  try {
    const nftContractFactory = await hre.ethers.deployContract("ChainBattles");

    const nftContract = await nftContractFactory.waitForDeployment();

    console.log("Contract deployed to: ", nftContract.target);
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

main();
