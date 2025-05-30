const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const platformWallet = deployer.address; // ou une autre adresse si tu veux

  const Factory = await hre.ethers.getContractFactory("TokenFactory");
  const factory = await Factory.deploy(platformWallet);

  await factory.deployed();
  console.log("✅ TokenFactory deployed to:", factory.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
