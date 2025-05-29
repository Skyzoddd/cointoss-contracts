require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  networks: {
    baseSepolia: {
      url: "https://sepolia.base.org",
      accounts: ["ec9dd5c460f45006270b19aa3e93ad65d9cc87c4fc17e297881a44fa1bc0b72b"]
    }
  }
};
