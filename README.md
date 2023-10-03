<!-- @format -->

# polygon-nft

## SAMPLE HARDHAT CONFIG FILE

    // hardhat.config.js

    require("@nomicfoundation/hardhat-toolbox");

    require("dotenv").config()

    // You need to export an object to set up your config
    // Go to https://hardhat.org/config/ to learn more

    const GOERLI_URL = process.env.GOERLI_URL;

    const PRIVATE_KEY = process.env.PRIVATE_KEY;

        module.exports = {

            solidity: "0.8.4",

            networks: {

                goerli: {

                    url: GOERLI_URL,

                    accounts: [PRIVATE_KEY]

                }

            }

        };

### Deployed contract address (polygon mumbai)

v1: 0x42BDeE9a94Cd8aB06D0c79B2114f7A595F178ea5

v2: 0x4F4a6719608Aa80E6e35Ea24d640735eb8039fB2

v3: 0x6652Fce06A0c0C7397f396B6C0D259B2e7fcc8b1

v4: 0x3E1aF451494163d1a698E8b8f9E30b4904087F00

v5: 0x87Be3F4012018Ff97d224E535dB087C1ba7342Ef

v6: 0xf79Fb2A66934666293A349EC4376460b6062A01c

v7: 0xB16148B4F5E6f981A109543688D88b9F26816B9C

v8: 0x1675F347564546Aae04f81207652a14477EC288E

v9: 0x7F1e599Fd2D123b9F2CfAd856376cB2A507015A1

v10: 0x057C2D44c3106C4098253ad9539818F4e7CD98D7

v11: 0x3f57AC457149D87a192B83F50280BBc83867b184

v12: 0x4fb5309a38a1a8f0a0f07c98a25682f0729D97E6

v13: 0x99B6C983C1c7fc9AD0cAff9a00032c74803c81dF

v14: 0x537034d161D3E3bA2708FAdE9d0a8852e9b90A86

v15: 0x2a83f6137C6C6D31612d2C88dC2b1D6C1d16a7bb

## Split Contract:

v1:
Contract deployed to: 0x90a821bBEc223ceB751f2057A449C89548c0bf23

CBAttack deployed at: 0xEF95DBb438F2e5dE045489182AC4ebc2f4325282

CBHeal deployed at: 0x2BC791166f02B665C5a100BbA8CF87f42fc97f71

CBMint deployed at: 0xbdA899422394B256Df58F9dA95319da8e5EDD621

CBRevive deployed at: 0xe6cAac02e8Aa3B42e4Ab13Af35E67fC635Ea94Bd

CBTrain deployed at: 0xB80F1453Bea86581D0925DB31c146A7867B773D0

https://mumbai.polygonscan.com/address/0x90a821bBEc223ceB751f2057A449C89548c0bf23
