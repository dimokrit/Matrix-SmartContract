require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-web3");


task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});


module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.14",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      // Forking MATIC
      //forking: {
        //url: `https://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY_MUMBAI}`,
        //blockNumber: 18812772,
      //}
    }
  },
  mocha: {
    timeout: 750000,
  }
};