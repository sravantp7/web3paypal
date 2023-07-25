const { ethers } = require("hardhat");
const { assert, expect } = require("chai");

describe("Paypal", function () {
  let Paypal;
  beforeEach(async function () {
    Paypal = await ethers.deployContract("Paypal"); // here first account will be used for deployment
    await Paypal.waitForDeployment();
  });

  describe("constructor", function () {
    it("should set owner as the deployer", async function () {
      const [signer] = await ethers.getSigners();
      const owner = await Paypal.owner();
      expect(owner).to.equal(await signer.getAddress());
    });
  });

  describe("addName", function () {
    it("user should able to add name to address", async function () {
      const [, user] = await ethers.getSigners();
      const tx = await Paypal.connect(user).addName("USER");
      await tx.wait();

      const [expectedResult] = await Paypal.getMyName(await user.getAddress()); // return the data as array of 2 items name and hasName
      expect(expectedResult).to.equal("USER");
    });
  });

  describe("createRequest", function () {
    it("user should able to create a new request", async function () {
      // adding name to user1
      const [, user1, user2] = await ethers.getSigners();
      const tx1 = await Paypal.connect(user1).addName("SAM");
      await tx1.wait();

      // ADDING NAME TO user2
      const tx = await Paypal.connect(user2).addName("BEN");
      await tx.wait();

      // creating a new request to user2 by user1
      const tx2 = await Paypal.connect(user1).createRequest(
        await user2.getAddress(),
        ethers.parseEther("1"),
        "Movie Snacks"
      );
      await tx2.wait();

      const data = await Paypal.connect(user2).getMyRequests(
        await user2.getAddress()
      ); // RETURN AN ARRAY OF ARRAYS OF VALUES

      expect(data[0][0]).to.equal(await user1.getAddress());
      expect(data[1][0]).to.equal(ethers.parseEther("1"));
      expect(data[2][0]).to.equal("Movie Snacks");
      expect(data[3][0]).to.equal("SAM");
    });
  });

  describe("payRequest", function () {
    it("should able to pay the request", async function () {
      // create a request.
      const [, user1, user2] = await ethers.getSigners();
      // adding name
      const tx1 = await Paypal.connect(user1).addName("JOY");
      await tx1.wait();

      const tx2 = await Paypal.connect(user2).addName("JIM");
      await tx2.wait();

      // USER1 Creating request to user2
      const tx3 = await Paypal.connect(user1).createRequest(
        await user2.getAddress(),
        ethers.parseEther("10"),
        "Pocket Money"
      );
      await tx3.wait();

      const user1BalanceAfterRequest = await ethers.provider.getBalance(
        await user1.getAddress()
      );

      const data = await Paypal.connect(user2).getMyRequests(
        await user2.getAddress()
      );
      expect(data[0][0]).to.equal(await user1.getAddress());

      // user2 paying the request at index 0
      const tx4 = await Paypal.connect(user2).payRequest(0, {
        value: ethers.parseEther("10"),
      });
      await tx4.wait();

      // getting the new eth balance of user1
      const user1NewBalance = await ethers.provider.getBalance(
        await user1.getAddress()
      );

      // checking whether the new balance of user1 is equal to old balance + requested amount
      expect(user1NewBalance).to.equal(
        user1BalanceAfterRequest + ethers.parseEther("10")
      );
    });
  });
});
