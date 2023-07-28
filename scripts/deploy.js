const { ethers } = require("hardhat");

// 0x437a10e0B3ac1bf8c9B582Ba7FD4a1A815Dfc56C

async function main() {
  const Paypal = await ethers.deployContract("Paypal");
  await Paypal.waitForDeployment();
  console.log(`Contract deployed at ${await Paypal.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
