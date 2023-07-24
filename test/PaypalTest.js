const { ethers } = require("hardhat");
const { assert, expect } = require("chai");

describe("Paypal", function () {
  let Paypal;
  beforeEach(async function () {
    Paypal = await ethers.deployContract("Paypal");
    await Paypal.waitForDeployment();
  });

  describe("constructor", function () {
    it("should set owner as the deployer", async function () {
      const [signer] = await ethers.getSigners();
      const owner = await Paypal.owner();
      expect(owner).to.equal(await signer.getAddress());
    });
  });
});
