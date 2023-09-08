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

0x42BDeE9a94Cd8aB06D0c79B2114f7A595F178ea5
new: 0x4F4a6719608Aa80E6e35Ea24d640735eb8039fB2
latest: 0x6652Fce06A0c0C7397f396B6C0D259B2e7fcc8b1

https://mumbai.polygonscan.com/address/0x6652Fce06A0c0C7397f396B6C0D259B2e7fcc8b1
