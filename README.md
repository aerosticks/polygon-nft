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

latest: 0x7F1e599Fd2D123b9F2CfAd856376cB2A507015A1

https://mumbai.polygonscan.com/address/0x7F1e599Fd2D123b9F2CfAd856376cB2A507015A1
