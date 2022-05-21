const { ethers } = require("hardhat");
const { expect } = require("chai");
const chai = require('chai')
const { BigNumber } = require("ethers");
const { solidity } = require('ethereum-waffle')

chai.use(solidity)

describe("LockV2", async () => {
    let owner, addr1;
    let lock2;
  
    beforeEach(async () => {
      [owner, addr1] = await ethers.getSigners();
  
      let lock = await ethers.getContractFactory("LockV2");
      lock2 = await lock.deploy();
      await lock2.deployed();
    });

    it("Confirm Deposited token is in users balance", async () => {
        await lock2.deposit(1000, {value: 100});
        expect((await lock2.balance()).toNumber() ).to.equal(100);
    });


    it("Should throw exception when trying to withdraw from empty wallet", async () => {
        await expect(lock2.withdraw()).to.be.revertedWith('No Token has been deposited in locking account');
    });

    it("Should throw exception when trying to withdraw from wallet before expiration", async () => {
        await lock2.deposit(1000, {value: 100});
        await expect(lock2.withdraw()).to.be.revertedWith('Token not mature for withdrawal');
    });
    
    it("Should withdraw from wallet when time elapses", async () => {
        await lock2.deposit(BigNumber.from(10), {value: 100});
        
        await ethers.provider.send('evm_increaseTime', [ 15 * 60]);

        expect(await lock2.withdraw()).to.emit(lock2, 'Withdraw');
    });

    it("Should withdraw from wallet with penalty even if time hasn't elapsed", async () => {
        await lock2.deposit(BigNumber.from(10), {value: 100});
        await expect(lock2.forceWithdraw())
        .to.emit(lock2, 'Withdraw')
        .withArgs(owner, 100 * 1/50);
    });

    it("Should withdraw from wallet with no penalty if time has elapsed", async () => {
        await lock2.deposit(BigNumber.from(10), {value: 100});

        await ethers.provider.send('evm_increaseTime', [ 15 * 60]);

        await expect(lock2.forceWithdraw())
        .to.emit(lock2, 'Withdraw')
        .withArgs(owner, 100);
    });
});