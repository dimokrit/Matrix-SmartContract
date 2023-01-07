const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require('@openzeppelin/test-helpers');
const { keccak256 } = require('keccak256');

describe("Matrix Constructor test Scenarios", function () {
  before(async () => {
    [governance, owner2, owner3, owner4, owner5, owner6, owner7] = await ethers.getSigners();
  });

  describe("Matrix test Scenario", async function () {
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
      console.log("Checks the Owners Settings")
      for(let i = 0; i < 5; i++) {
        let owner = Owners[i];
        const ownerStruct = await matrix.users(owner.address);
        expect(ownerStruct.id).to.equal(ethers.BigNumber.from((i+1).toString()));
        console.log(`Owner ${i + 1} id = ${ownerStruct.id}, test passed`);
        expect(ownerStruct.referrer).to.equal(owner.address);
        console.log(`Owner ${i + 1} referrer = ${ownerStruct.referrer}, test passed`);
        expect(ownerStruct.levelsInRow).to.equal(12);
        console.log(`Owner ${i + 1} levels in row = ${ownerStruct.levelsInRow}, test passed`);
      }
      console.log("Checks the level Price, min free second level & min free first level");
      for(let i = 1; i < 16; i++) {
        const levelPrice = await matrix.levelPrice(i);
        const minFreeSecondLevelStructure = await matrix.minFreeSecondLevelStructure(i);
        const minFreeFirstLevelStructure = await matrix.minFreeFirstLevelStructure(i);
        expect(levelPrice).to.equal("100");
        console.log(`Level ${i} price = ${levelPrice}, test passed`);
        expect(minFreeSecondLevelStructure).to.equal("1");
        console.log(`Level ${i} minFreeSecondLevelStructure = ${minFreeSecondLevelStructure}, test passed`);
        expect(minFreeFirstLevelStructure).to.equal("2");
        console.log(`Level ${i} minFreeFirstLevelStructure = ${minFreeFirstLevelStructure}, test passed`);
      }
    });
  });
});
