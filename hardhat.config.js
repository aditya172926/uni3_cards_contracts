require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()
require("@nomiclabs/hardhat-ethers");

const { PRIVATE_KEY, API_URL } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
};

module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "polygon_mumbai",
  networks: {
     hardhat: {},
     polygon_mumbai: {
        url: API_URL,
        accounts: [`0x${PRIVATE_KEY}`]
     }
  },
}
