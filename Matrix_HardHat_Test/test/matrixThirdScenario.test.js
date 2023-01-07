const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require('@openzeppelin/test-helpers');
const { keccak256 } = require('keccak256');
let players = [];
describe("Matrix Second Test Scenario", function () {
  before(async () => {
    [governance, owner2, owner3, owner4, owner5, owner6, owner7] = await ethers.getSigners();
    for(let i = 0; i < 50; i++) {
      let player = ethers.Wallet.createRandom();
      player =  player.connect(ethers.provider);
      await owner2.sendTransaction({to: player.address, value: ethers.utils.parseEther("1")});
      players.push(player);
    }
  });

  describe("Matrix test Scenarios", async function () {
    let matrix;
    it("Should deploy the contract without errors", async function () {
      const Matrix = await ethers.getContractFactory("Matrix1");
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
    it("Should open level 1 to 15 without error", async function() {
      for(let i = 1; i <= 15; i++){
        await matrix.openLevel(i);
        expect(await matrix.levelIsAvailable(i)).to.equal(true);
      }
    });
    it("Should register user 1 witn referral owner1", async function() {
      await matrix.connect(players[0]).registrationExt(governance.address, {value: "100"});
      const playerStruct = await matrix.connect(players[0]).users(players[0].address);
      expect(playerStruct.id).to.equal(6);
      expect(playerStruct.referrer).to.equal(governance.address);
      expect(await matrix.connect(players[0]).idToAddress(6)).to.equal(players[0].address);
    });
    it("Should register users 2 to 11 witn referral user[i-1]", async function() {
      let j = 7;
      for(let i = 1; i < 11; i++){
        await matrix.connect(players[i]).registrationExt(players[i-1].address, {value: "100"});
        const playerStruct = await matrix.connect(players[i]).users(players[i].address);
        expect(playerStruct.id).to.equal(j);
        expect(playerStruct.referrer).to.equal(players[i-1].address);
        expect(await matrix.connect(players[i]).idToAddress(j)).to.equal(players[i].address);
        j++;
      }
    });
    it("Should register user 12 witn referral owner1", async function() {
      await matrix.connect(players[11]).registrationExt(governance.address, {value: "100"});
      const playerStruct = await matrix.connect(players[11]).users(players[11].address);
      expect(playerStruct.id).to.equal(17);
      expect(playerStruct.referrer).to.equal(governance.address);
      expect(await matrix.connect(players[11]).idToAddress(17)).to.equal(players[11].address);
    });
    it("Should register users 13 to 50 witn referral user[i-1]", async function() {
      let j = 18;
      for(let i = 12; i < 50; i++){
        await matrix.connect(players[i]).registrationExt(players[i-1].address, {value: "100"});
        const playerStruct = await matrix.connect(players[i]).users(players[i].address);
        expect(playerStruct.id).to.equal(j);
        expect(playerStruct.referrer).to.equal(players[i-1].address);
        expect(await matrix.connect(players[i]).idToAddress(j)).to.equal(players[i].address);
        j++;
      }
    });
    it("Before 5 minutes should let user 1 to 11 buy the level 1", async function() {
      for(let i = 0; i < 11; i++){
        await matrix.connect(players[i]).buyNewLevel(1, {value: "100"});
        let user = await matrix.userDataes(1, players[i].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
      await time.increase(time.duration.minutes(5));
    });
    it("Should let user 11 buy the level 1 after 5 minutes", async function() {
      await matrix.connect(players[10]).buyNewLevel(1, {value: "100"});
      let user = await matrix.userDataes(1, players[10].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
    });
    it("Should let user 14 to 20 buy the level 1 after 5 minutes", async function() {
      for(let i = 13; i < 20; i++){
        await matrix.connect(players[i]).buyNewLevel(1, {value: "100"});
        let user = await matrix.userDataes(1, players[i].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should let user 1 buy the level 2 to 15", async function() {
      for(let i = 2; i < 16; i ++){
        await matrix.connect(players[0]).buyNewLevel(i, {value: "100"});
        let user = await matrix.userDataes(i, players[0].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should let user 2 buy the level 2 to 15", async function() {
      for(let i = 2; i < 16; i ++){
        await matrix.connect(players[1]).buyNewLevel(i, {value: "100"});
        let user = await matrix.userDataes(i, players[1].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should let user 3 buy the level 2 to 8", async function() {
      for(let i = 2; i < 9; i ++){
        await matrix.connect(players[2]).buyNewLevel(i, {value: "100"});
        let user = await matrix.userDataes(i, players[2].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should let user 4 buy the level 2 to 9", async function() {
      for(let i = 2; i < 10; i ++){
        await matrix.connect(players[3]).buyNewLevel(i, {value: "100"});
        let user = await matrix.userDataes(i, players[3].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should let user 5 buy the level 2 to 15", async function() {
      for(let i = 2; i < 16; i ++){
        await matrix.connect(players[4]).buyNewLevel(i, {value: "100"});
        let user = await matrix.userDataes(i, players[4].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should let user 6 to 36 buy the level 2 without error", async function() {
      for(let i = 5; i < 36; i ++){
        await matrix.connect(players[i]).buyNewLevel(2, {value: "100"});
        let user = await matrix.userDataes(2, players[i].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should let user 6 to 47 buy the level 11 without error", async function() {
      for(let i = 5; i < 47; i ++){
        await matrix.connect(players[i]).buyNewLevel(11, {value: "100"});
        let user = await matrix.userDataes(11, players[i].address);
        let levelIsActive = user.levelIsActive;
        expect(levelIsActive).to.equal(true);
      }
    });
    it("Should return expected referral rewards to users 1 to 4", async function() {
      for(let i = 0; i < 4; i++){
        let userReferralRewards = await matrix.UserRefferalRewards(players[i].address);
        expect(userReferralRewards[1]).to.equal(23);
      }
    });
    it("Should return expected referral rewards to user 5", async function() {
      let userReferralRewards = await matrix.UserRefferalRewards(players[4].address);
      expect(userReferralRewards[1]).to.equal(22);
    });
    it("Should return expected referral rewards to user 6", async function() {
      let userReferralRewards = await matrix.UserRefferalRewards(players[5].address);
      expect(userReferralRewards[1]).to.equal(20);
    });
    it("Should return expected referral rewards to user 7", async function() {
      let userReferralRewards = await matrix.UserRefferalRewards(players[6].address);
      expect(userReferralRewards[1]).to.equal(18);
    });
    it("Should return expected referral rewards to user 8", async function() {
      let userReferralRewards = await matrix.UserRefferalRewards(players[7].address);
      expect(userReferralRewards[1]).to.equal(16);
    });
    it("Should return expected referral rewards to user 9", async function() {
      let userReferralRewards = await matrix.UserRefferalRewards(players[8].address);
      expect(userReferralRewards[1]).to.equal(13);
    });
    it("Should return expected referral rewards to user 10", async function() {
      let userReferralRewards = await matrix.UserRefferalRewards(players[9].address);
      expect(userReferralRewards[1]).to.equal(8);
    });
    it("Should return expected referral rewards to user 11", async function() {
      let userReferralRewards = await matrix.UserRefferalRewards(players[10].address);
      expect(userReferralRewards[1]).to.equal(0);
    });
    it("Should return expected losted money to user 12", async function() {
      let user = await matrix.userDataes(1, players[11].address);
      let userLostedMoney = user.lostedMoney
      expect(userLostedMoney).to.equal(15);
    });
    it("Should return expected losted money to user 13", async function() {
      let user = await matrix.userDataes(1, players[12].address);
      let userLostedMoney = user.lostedMoney
      expect(userLostedMoney).to.equal(23);
    });
    it("Should return expected user befor payment to user 20", async function() {
      let user = await matrix.userDataes(1, players[19].address);
      let usersBeforePayment = user.usersBeforePayment;
      expect(usersBeforePayment).to.equal(20);
    });
    it("Should return expected user befor payment to user 5", async function() {
      let user = await matrix.userDataes(1, players[4].address);
      let usersBeforePayment = user.usersBeforePayment;
      expect(usersBeforePayment).to.equal(44);
    });
    it("Should return expected user befor payment to user 3", async function() {
      let user = await matrix.userDataes(1, players[2].address);
      let usersBeforePayment = user.usersBeforePayment;
      expect(usersBeforePayment).to.equal(3);
    });
    it("Should return expected levels in row & BR to user 1", async function() {
      let user = await matrix.userDataes(1, players[0].address);
      let levelsInRow = user.levelsInRow;
      let extraBR = user.extraBR;
      expect(levelsInRow).to.equal(0);
      expect(extraBR).to.equal(0);
    });
    it("Should return expected levels in row & BR to user 2", async function() {
      let user = await matrix.userDataes(1, players[1].address);
      let levelsInRow = user.levelsInRow;
      let extraBR = user.extraBR;
      expect(levelsInRow).to.equal(10);
      expect(extraBR).to.equal(58);
    });
    it("Should return expected levels in row & BR to user 3", async function() {
      let user = await matrix.userDataes(1, players[2].address);
      let levelsInRow = user.levelsInRow;
      let extraBR = user.extraBR;
      expect(levelsInRow).to.equal(0);
      expect(extraBR).to.equal(0);
    });
    it("Should return expected levels in row & BR to user 4", async function() {
      let user = await matrix.userDataes(1, players[3].address);
      let levelsInRow = user.levelsInRow;
      let extraBR = user.extraBR;
      expect(levelsInRow).to.equal(9);
      expect(extraBR).to.equal(56);
    });
    it("Should return expected levels in row & BR to user 5", async function() {
      let user = await matrix.userDataes(1, players[4].address);
      let levelsInRow = user.levelsInRow;
      let extraBR = user.extraBR;
      expect(levelsInRow).to.equal(15);
      expect(extraBR).to.equal(75);
    });
  });
});
