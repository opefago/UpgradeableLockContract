const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Proxy", async () => {
    let owner, addr1;
    let proxy, lock1, lock2;
  
    beforeEach(async () => {
      [owner, addr1] = await ethers.getSigners();
  
      let lock = await ethers.getContractFactory("LockV1");
      lock1 = await lock.deploy();
      await lock1.deployed();

      lock = await ethers.getContractFactory("LockV2");
      lock2 = await lock.deploy();
      await lock2.deployed();
  
      const Proxy = await ethers.getContractFactory("Proxy");
      proxy = await Proxy.deploy(owner.address, lock1.address);
      await proxy.deployed();
    });

    it("points to an implementation contract", async () => {
      expect(await proxy.getImplementation()).to.eq(lock1.address);
    });

    it("switches implementation contract", async () => {
      await proxy.setImplementation(lock2.address)
      expect(await proxy.getImplementation()).to.eq(lock2.address);
    });

    it("A different account cannot change contract implementation", async () => {
      await expect(proxy.connect(addr1).setImplementation(lock2.address)).to.be.revertedWith('Invalid Admin!');
    });

    it("when admin is changed, should not be able to change implementation with old admin", async () => {
      proxy.setAdmin(addr1.address);
      await expect(proxy.setImplementation(lock2.address)).to.be.revertedWith('Invalid Admin!');
    });

    it("when admin is changed, should be able to change implementation with new admin", async () => {
      proxy.setAdmin(addr1.address);
      await proxy.connect(addr1).setImplementation(lock2.address)
      expect(await proxy.getImplementation()).to.eq(lock2.address);
    });

    it("A different account should not be able to change admin", async () => {
      await expect(proxy.connect(addr1).setAdmin(addr1.address)).to.be.revertedWith('Invalid Admin!');
    });

    it("Proxy calls implementation contract", async () => {

      abi = [
        "function deposit(uint256 duration_in_seconds) external payable",
        "function withdraw() public",
        "function balance() public view returns(uint256)"
      ]

      const proxied = new ethers.Contract(proxy.address, abi, owner);

      await proxied.deposit(1000, {value: 100});
      expect((await proxied.balance()).toNumber() ).to.equal(100);
    });
});