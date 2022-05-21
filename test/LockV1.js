const { ethers } = require("hardhat");
const { expect } = require("chai");
const chai = require('chai')
const { BigNumber } = require("ethers");
const { solidity } = require('ethereum-waffle')

chai.use(solidity)

describe("LockV1", async () => {
    let owner;
    let lock1;
  
    beforeEach(async () => {
      [owner] = await ethers.getSigners();
  
      let lock = await ethers.getContractFactory("LockV1");
      lock1 = await lock.deploy();
      await lock1.deployed();
    });

    it("Confirm Deposited token is in users balance", async () => {
        await lock1.deposit(1000, {value: 100});
        expect((await lock1.balance()).toNumber() ).to.equal(100);
    });


    it("Should throw exception when trying to withdraw from empty wallet", async () => {
        await expect(lock1.withdraw()).to.be.revertedWith('No Token has been deposited in locking account');
    });

    it("Should throw exception when trying to withdraw from wallet before expiration", async () => {
        await lock1.deposit(1000, {value: 100});
        await expect(lock1.withdraw())
        .to.be.revertedWith('Token not mature for withdrawal');
    });
    
    it("Should withdraw from wallet when time elapses", async () => {
        await lock1.deposit(BigNumber.from(10), {value: 100});
        
        await ethers.provider.send('evm_increaseTime', [ 15 * 60]);

        expect(await lock1.withdraw()).to.emit(lock1, 'Withdraw');
    });
});