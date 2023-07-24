const { ethers } = require("hardhat");

// 0xE6189E1925cA3aD75f714e3338D865E5192bEF37

async function main() {
  const Paypal = await ethers.deployContract("Paypal");
  await Paypal.waitForDeployment();
  console.log(`Contract deployed at ${await Paypal.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
