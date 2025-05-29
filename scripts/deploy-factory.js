const hre = require("hardhat");

async function main() {
  const routerAddress = "0x327Df1E6de05895d2ab08513aaDD9313Fe505d86"; // Uniswap router on Base Sepolia
  const Factory = await hre.ethers.getContractFactory("TokenFactory");
  const factory = await Factory.deploy(routerAddress);
  await factory.deployed();
  console.log("Factory deployed to:", factory.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});