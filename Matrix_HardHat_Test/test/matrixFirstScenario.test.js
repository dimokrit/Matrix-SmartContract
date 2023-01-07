const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require('@openzeppelin/test-helpers');
let players = [];
describe("Matrix First Test Scenario", function () {
  before(async () => {
    [governance, owner2, owner3, owner4, owner5, owner6, owner7] = await ethers.getSigners();
    for(let i = 0; i < 100; i++) {
      let player = ethers.Wallet.createRandom();
      player =  player.connect(ethers.provider);
      await owner2.sendTransaction({to: player.address, value: ethers.utils.parseEther("1")});
      players.push(player);
    }
  });

  describe("Matrix test Scenarios", async function () {
    let matrix;
    it("Should deploy the contract without errors", async function () {
      const Matrix = await ethers.getContractFactory("Name");
      matrix = await Matrix.deploy(
        governance.address, 
        owner2.address, 
        owner3.address, 
        owner4.address, 
        owner5.address, 
        owner6.address, 
        owner7.address
        );
      await matrix.deployed();
      let Owners = [
        governance,
        owner2, 
        owner3, 
        owner4, 
        owner5
      ];
      //Checks the Owners
      for(let i = 0; i < 5; i++) {
        let owner = Owners[i];
        const ownerStruct = await matrix.users(owner.address);
        expect(ownerStruct.id).to.equal(ethers.BigNumber.from((i+1).toString()));
        expect(ownerStruct.referrer).to.equal(owner.address);
        expect(ownerStruct.levelsInRow).to.equal(12);
      }
      //Checks the level Price, min free second level & min free first level
      for(let i = 1; i < 16; i++) {
        const levelPrice = await matrix.levelPrice(i);
        const minFreeSecondLevelStructure = await matrix.minFreeSecondLevelStructure(i);
        const minFreeFirstLevelStructure = await matrix.minFreeFirstLevelStructure(i);
        expect(levelPrice).to.equal("100");
        expect(minFreeSecondLevelStructure).to.equal("1");
        expect(minFreeFirstLevelStructure).to.equal("2");
      }
    });
    it("Should register 100 players", async function() {
      let j = 6;
      for(let i = 0; i < 100; i++){
        await matrix.connect(players[i]).registrationExt(governance.address, {value: "100"});
        const playerStruct = await matrix.connect(players[i]).users(players[i].address);
        expect(playerStruct.id).to.equal(j);
        expect(playerStruct.referrer).to.equal(governance.address);
        expect(await matrix.connect(players[i]).idToAddress(j)).to.equal(players[i].address);
        j++;
      }
    });
    it("Should open level 1 without error", async function() {
      await matrix.openLevel(1);
      expect(await matrix.levelIsAvailable(1)).to.equal(true);
    });
    it("Should let all the users buy the level 1", async function() {
      for(let i = 0; i < players.length; i++){
        await matrix.connect(players[i]).buyNewLevel(1, {value: "100"});
      }
    });
    it("Should verify the structure9 & structure12 data in level 1 without error", async function() {
      let [, 
        mainTableLevel1Structure12, 
        , 
        secondTableLevel1Structure12,
        ,
      ] = await matrix.structureDates(12, 1);
      
      expect(mainTableLevel1Structure12).to.equal(governance.address);
      expect(secondTableLevel1Structure12[5]).to.equal(await matrix.idToAddress(77));

      let [, 
        mainTableLevel1Structure9, 
        firstTableLevel1Structure9, 
        ,
        ,
      ] = await matrix.structureDates(9, 1);

      let id30 = await matrix.idToAddress(30);
      let id31 = await matrix.idToAddress(31);
      let id32 = await matrix.idToAddress(32);
      let id33 = await matrix.idToAddress(33);

      expect(mainTableLevel1Structure9).to.equal(await matrix.idToAddress(9));
      expect(firstTableLevel1Structure9[0]).to.equal(id30);
      expect(firstTableLevel1Structure9[1]).to.equal(id31);
      expect(firstTableLevel1Structure9[2]).to.equal(id32);
      expect(firstTableLevel1Structure9[3]).to.equal(id33);
    });
  });
});