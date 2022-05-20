describe("Proxy", async () => {
    let owner;
    let proxy, logic;
  
    beforeEach(async () => {
      [owner] = await ethers.getSigners();
  
      const Logic = await ethers.getContractFactory("Logic");
      logic = await Logic.deploy();
      await logic.deployed();
  
      const Proxy = await ethers.getContractFactory("Proxy");
      proxy = await Proxy.deploy();
      await proxy.deployed();
  
      await proxy.setImplementation(logic.address);
    });

    it("points to an implementation contract", async () => {
        expect(await proxy.implementation()).to.eq(logic.address);
      });
});