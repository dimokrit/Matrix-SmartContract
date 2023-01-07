// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract insurance {
    
    address owner;
    address cryptoSpaceAddress;
    mapping (address =>uint) insuranceDates;
    mapping (uint => address) insuranceAddresses;
    uint addressesCounter;
    uint addressesCounterSave;
    bool public insuranceWasSent;

    event addUser(uint indexed userId, address indexed userAddress, uint indexed insuranceAmount);

    constructor(address _owner){
        owner = _owner;
    }
    receive() external payable{}

    modifier onlyOwner() {
      require(owner == msg.sender, "Ownable: caller is not the owner");
      _;
    }

    modifier onlyCryptoSpace() {
      require(cryptoSpaceAddress == msg.sender, "Ownable: caller is not the owner");
      _;
    }

    function setCryptoSpaceAddress(address _cryptoSpaceAddress) external onlyOwner {
        cryptoSpaceAddress = _cryptoSpaceAddress;
    }

    function writeInsuranceDates(uint256 Ipayment, address Iaddress) external onlyCryptoSpace {
        addressesCounter++;
        addressesCounterSave++;
        insuranceAddresses[addressesCounter] = Iaddress;
        insuranceDates[Iaddress] = Ipayment;
        emit addUser(addressesCounter, Iaddress, Ipayment);
    }

    function payment() external payable onlyCryptoSpace {
        uint num1;
        uint num2;
        if ((addressesCounter / 200) > 0) {
            addressesCounter -= 200;
            num1 = addressesCounterSave - addressesCounter;
            num2 = 199;
        } else {
            num1 = addressesCounterSave;
            num2 = addressesCounter - 1;
            insuranceWasSent = true;
        }
        for (uint i = num1 - num2; i <= num1; i++) {
                address payable rec = payable (insuranceAddresses[i]);
                uint amount = insuranceDates[rec];
                (bool success, ) = rec.call{value: amount}("");
                require(success, "Failed to send insurance");
        }
    }

    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    function withdraw(address _receiver) external onlyOwner {
        (bool success, ) = _receiver.call{value: address(this).balance}("");
        require(success, "Failed");
    }
}