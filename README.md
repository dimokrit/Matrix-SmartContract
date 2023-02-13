<p align="center">
      <img src="https://drive.google.com/uc?export=view&id=1Ntwb0XvXqPg5tTPs4wEMCTfx4T1vylAk" alt ="Project logo" width="726">
</p>

<p align="center">
   <img src="https://img.shields.io/badge/Solidity-0.8.9-lightgrey" alt="Solidity Version">
   <img src="https://img.shields.io/badge/HardHat-2.9.7-red" alt="HardHat Version">
   <img src="https://img.shields.io/badge/Blockchain-BSC-yellow" alt="Blockchain">
   <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

## About

A matrix-type project with a narrowing structure. It has 15 levels with different costs and different amounts of rewards, a 7-level referral system in which a system of passes and freezes works. All payments are made automatically, Сryptospace is equipped with the function of insurance payments. More than 500 bloggers and leaders are involved in the project

Project website [CryptoSpace](https://crypto-space.games).
      
The levels open in turn, at a certain time.
In the system user can get referral reward, when his referral buy level, but the user must also have purchased this level.
The system of freezes gives users 10 minutes after opening a level, for buying the level and gets referral reward, if his referral bougth it before.
The insurance gives the user a guarantee of receiving 20% of the cost of the level, if he does not receive at least one payment from it before the end of the project.
Storage and realization of the insuranse is written in the insuranse.sol.

Also you can see tests of this contract with 3 scenarios, written on the JS, using HardHat.
      
## Documentation

### User functions
- **-** **`registration`** - Registration in the system. Gets address of user's upline.
- **-** **`buyNewLvl`** - Buying level in the matrix system with insurance. Gets number of level (max is 15 level).
- **-** **`buyNewLvlWI`** - Buying level in the matrix system without insurance. Gets number of level (max is 15 level).

### Owner functions
- **-** **`setlevelStartTime`** - Sets the opening time of the level. Gets number of the level and time in UNIX.
- **-** **`countFrzdRefRew`** - Counts referral reward after 10 minutes waiting for each user (have to be called before 'sendFreezedReferralRewards'). Gets number of the level.
- **-** **`sendFreezedReferralRewards`** - Sents referral reward after 10 minutes waiting. Gets number of the level.
- **-** **`writeIData`** - Writes insuranse data in the smartcontract insuranse.sol (have to be called before 'paymentOfInsurance').
- **-** **`paymentOfInsurance`** - Sent insuranse payments from insuranse.sol.

## Developers

[dimokrit](https://github.com/dimokrit)
[Aar0nWalker](https://github.com/Aar0nWalker)

## License

Project CryptoSpace.Matrix is distributed under the MIT license
