const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require('@openzeppelin/test-helpers');
const { keccak256 } = require('keccak256');
let players = [];
describe("Matrix Second Test Scenario", function () {
  before(async () => {
    [governance, owner2, owner3, owner4, owner5, owner6, owner7] = await ethers.getSigners();
    for(let i = 0; i < 1000; i++) {
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
    it("Should register 1000 players", async function() {
      let j = 6;
      for(let i = 0; i < 1000; i++){
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
        if(i == 22 || i == 184 || i == 508 || i == 850 || i == 909 || i == 987 ){
          await matrix.connect(players[i]).buyNewLevelWithInsurance(1, {value: "105"});
          continue;
        }
        await matrix.connect(players[i]).buyNewLevel(1, {value: "100"});
      }
    });
    it("Should verify the structure121 data in level 1 without error", async function() {
      let [structure121Id,
        mainTableLevel1Structure121, 
        firstTableLevel1Structure121, 
        secondTableLevel1Structure121,
        freePlace,
        blocked
      ] = await matrix.structureDates(125, 1);
      console.log("Structure Id: ", structure121Id);
      console.log("Main Table Address: ", mainTableLevel1Structure121);
      console.log("Main Table Address ID: ", (await matrix.users(mainTableLevel1Structure121)).id);
      console.log("Second Line Addresses: ", firstTableLevel1Structure121);
      for(let i = 0; i < 4; i++){
        console.log(`Second Line Address ${i+1} ID: `, (await matrix.users(firstTableLevel1Structure121[i])).id);
      }
      console.log("Third Line Addresses: ", secondTableLevel1Structure121);
      for(let i = 0; i < 6; i++){
        console.log(`Third Line Address ${i+1} ID: `, (await matrix.users(secondTableLevel1Structure121[i])).id);
      }
      console.log("Free Places: ", freePlace);
      console.log("Is blocked: ", blocked);
    });
    it("Should verify the structure125 data in level 1 without error", async function() {
      let [structure125Id, 
        mainTableLevel1Structure125, 
        firstTableLevel1Structure125, 
        secondTableLevel1Structure125,
        freePlace,
        blocked
      ] = await matrix.structureDates(125, 1);
      
      let user = await matrix.users(mainTableLevel1Structure125);
      let minFreeFirstLevelStructure = await matrix.minFreeFirstLevelStructure(1);
      let minFreeSecondLevelStructure = await matrix.minFreeSecondLevelStructure(1);
      console.log("Min Free First Level Structure: ", minFreeFirstLevelStructure);
      console.log("Min Free Second Level Structure: ", minFreeSecondLevelStructure);
      console.log("Structure Id: ", structure125Id);
      console.log("Main Table Address: ", mainTableLevel1Structure125);
      console.log("Main Table Address ID: ", (await matrix.users(mainTableLevel1Structure125)).id);
      console.log("Second Line Addresses: ", firstTableLevel1Structure125);
      for(let i = 0; i < 4; i++){
        console.log(`Second Line Address ${i+1} ID: `, (await matrix.users(firstTableLevel1Structure125[i])).id);
      }
      console.log("Third Line Addresses: ", secondTableLevel1Structure125);
      for(let i = 0; i < 6; i++){
        console.log(`Third Line Address ${i+1} ID: `, (await matrix.users(secondTableLevel1Structure125[i])).id);
      }
      console.log("Free Places: ", freePlace);
      console.log("Is blocked: ", blocked);
      //expect(mainTableLevel1Structure125).to.equal(owner2.address);
      expect(secondTableLevel1Structure125[5]).to.equal(await matrix.idToAddress(755));      
    });
  });
});
