/** @format */

const hre = require("hardhat");

async function getCharStats(tokenId) {
  console.log(
    "Character stats for token #",
    tokenId,
    "\n",
    await hre.ethers.provider.getCharacterStats(tokenId)
  );
}

async function main() {
  const [owner, user1, user2, user3] = await hre.ethers.getSigners();

  const ChainBattlesFactory = await hre.ethers.getContractFactory(
    "ChainBattles"
  );
  const chainBattles = await ChainBattlesFactory.deploy();
  //   await chainBattles.deployTransaction.wait();
  await chainBattles.waitForDeployment();
  console.log("ChainBattles deployed to:", chainBattles.target);

  //   const addresses = [
  //     owner.address,
  //     user1.address,
  //     user2.address,
  //     user3.address,
  //   ];

  await chainBattles.connect(owner).mint();
  console.log(
    "Character stats for token #",
    1,
    "\n",
    await chainBattles.getCharacterStats(1)
  );

  // await chainBattles.connect(owner).train(1);
  // console.log(
  //   "Character stats for token # TRAINED",
  //   1,
  //   "\n",
  //   await chainBattles.getCharacterStats(1)
  // );

  await chainBattles.connect(user1).mint();
  console.log(
    "Character stats for token #",
    2,
    "\n",
    await chainBattles.getCharacterStats(2)
  );

  // await chainBattles.connect(user1).train(2);
  // console.log(
  //   "Character stats for token # TRAINED",
  //   2,
  //   "\n",
  //   await chainBattles.getCharacterStats(2)
  // );

  await chainBattles.connect(user2).mint();
  console.log(
    "Character stats for token #",
    3,
    "\n",
    await chainBattles.getCharacterStats(3)
  );

  // await chainBattles.connect(user2).train(3);
  // console.log(
  //   "Character stats for token # TRAINED",
  //   3,
  //   "\n",
  //   await chainBattles.getCharacterStats(3)
  // );

  await chainBattles.connect(user3).mint();
  console.log(
    "Character stats for token #",
    4,
    "\n",
    await chainBattles.getCharacterStats(4)
  );

  // await chainBattles.connect(user3).train(4);
  // console.log(
  //   "Character stats for token # TRAINED",
  //   4,
  //   "\n",
  //   await chainBattles.getCharacterStats(4)
  // );

  await chainBattles.connect(owner).attack(1, 2);
  console.log(
    "Character stats for token after attack 1 token 1 -> 2",
    "\n",
    await chainBattles.getCharacterStats(2)
  );
  await chainBattles.connect(owner).attack(1, 2);
  console.log(
    "Character stats for token after attack 2 token 1 -> 2",
    "\n",
    await chainBattles.getCharacterStats(2)
  );
  await chainBattles.connect(owner).attack(1, 2);
  console.log(
    "Character stats for token after attack 3 token 1 -> 2",
    "\n",
    await chainBattles.getCharacterStats(2)
  );

  console.log("XP POINTS ", owner.address, "\n", await chainBattles.getXP());

  await chainBattles.train(1);

  console.log(
    "XP FOR NEXT LEVEL on TOKEN 1 ",
    await chainBattles.getAmountForNextLevel(1)
  );
  await chainBattles.train(1);

  console.log(
    "XP FOR NEXT LEVEL on TOKEN 1 ",
    await chainBattles.getAmountForNextLevel(1)
  );
  await chainBattles.train(1);

  console.log(
    "XP FOR NEXT LEVEL on TOKEN 1 ",
    await chainBattles.getAmountForNextLevel(1)
  );

  // console.log("TOKEN URI\n", await chainBattles.tokenURI(2));
}

main().then(() =>
  process.exit(0).catch(error => {
    console.error(error);
    process.exit(1);
  })
);
