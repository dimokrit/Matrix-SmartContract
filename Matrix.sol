//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

contract CryptoSpace {
    struct User {
        uint256 id;
        address ref;
        uint256 lvlInRow;
        uint256 extraBR;
        mapping(uint256 => uint256) lostMoney;
        mapping(uint256 => uint256) frzdRefReward;
        mapping(uint256 => bool) lvlWasAct;
        mapping(uint256 => bool) lvlIsAct;
        mapping(uint256 => uint256) place;
        mapping(uint256 => uint256) AbsPlace;
        mapping(uint256 => uint256) usersBP;
        mapping(uint256 => bool) Insurance;
        mapping(uint256 => uint256) gottenRewards;
        mapping(uint256 => uint256) gottenRefReward;
        mapping(uint256 => uint256) reinvests;
    }

    struct Structure {
        uint256 StrId;
        address mainStrLvl;
        address[4] firstStrLvl;
        address[6] secondStrLvl;
        uint256 freePlace;
    }

    struct Level {
        uint256 freeAbsPlace;
        mapping(uint256 => Structure) idToStr;
    }

    uint256 constant lastLvl = 15;
    uint256 lastUserId = 5;
    uint256 lastIUserId;
    uint256 lastIUserIdSave;
    uint256 registrationCost = 90000000000000000 wei;
    uint256 public startProjectTime;
    bool insuranceWasSent;

    mapping(uint256 => Level) lvlToStr;
    mapping(address => User) users;
    mapping(uint256 => address) idToAddr;
    mapping(uint256 => uint256) freeSecondLvl;
    mapping(uint256 => uint256) freeFirstLvl;
    bool[16] public lvlIsAv;
    mapping(uint256 => mapping(uint256 => address)) pAddr;
    mapping(uint256 => mapping(address => uint256)) wRR;
    mapping(uint256 => mapping(uint256 => address)) wRRAddr;
    mapping(uint256 => uint256) numOfFrzdRef;
    mapping(uint256 => uint256) numOfFrzdRefSave;
    mapping(uint256 => bool) expLvl;
    mapping(uint256 => uint256) nOfPA;
    mapping(uint256 => uint256) nOfPASave;
    mapping(uint256 => uint256) levelStartTime;
    mapping(uint256 => uint256) refRewardsSendTime;
    mapping(uint256 => uint256) usersAtLvl;
    mapping(uint256 => uint256) reinvCount;
    mapping(address => uint256) public IPayments;
    mapping(address => uint256) IIds;
    mapping(uint256 => address) IAddrs;

    mapping(uint256 => uint256) public lvlPrice;
    mapping(uint256 => uint256) public BRPercent;
    mapping(uint256 => uint256) public refPercent;

    mapping(uint256 => address) owners;

    event Registration(
        address indexed user,
        address indexed referrer,
        uint256 userId,
        uint256 referrerId
    );
    event NewUserPlace(
        address indexed user,
        uint256 indexed structure,
        uint256 level,
        uint256 place,
        bool indexed insurance
    );

    constructor(address ownerAddr, address ownerAddr1, address ownerAddr2, address ownerAddr3, address ownerAddr4, address insuranceAddr, address marketingAddr) {
        serValues();
        startProjectTime = block.timestamp;
        owners[1] = ownerAddr;
        owners[2] = ownerAddr1;
        owners[3] = ownerAddr2;
        owners[4] = ownerAddr3;
        owners[5] = ownerAddr4;
        owners[6] = insuranceAddr;
        owners[7] = marketingAddr;

        Structure memory structure = Structure({
            StrId: 1,
            mainStrLvl: owners[1],
            firstStrLvl: [owners[2], owners[3], owners[4], owners[5]],
            secondStrLvl: [address(0), address(0), address(0), address(0), address(0), address(0)],
            freePlace: 6
        });

        for (uint256 i = 1; i <= 5; i++) {
            users[owners[i]].id = i;
            users[owners[i]].ref = owners[i];
            users[owners[i]].lvlInRow = 15;
            idToAddr[i] = owners[i];
        }

        for (uint256 i = 1; i <= lastLvl; i++) {
            for (uint256 j = 1; j <= 5; j++) {
                users[owners[j]].lvlWasAct[i] = true;
                users[owners[j]].lvlIsAct[i] = true;
                users[owners[j]].place[i] = j;
                users[owners[j]].AbsPlace[i] = j;
            }
            lvlToStr[i].idToStr[1] = structure;
            lvlToStr[i].freeAbsPlace = 6;
            usersAtLvl[i] = 5;
        }
    }

    modifier onlyOwner() {
        require(owners[1] == msg.sender, "only owner");
        _;
    }

    modifier levelIsOpen(uint256 lvl) {
        require(block.timestamp >= levelStartTime[lvl] && levelStartTime[lvl] > 0, "level closed");
        _;
    }

    function registration(address refAddr) external payable {
        registrationInt(msg.sender, refAddr);
    }

    function registrationInt(address user, address refAddr) private {
        require(msg.value == registrationCost, "wrong value");
        require(!isUserExists(user), "user already exists");
        require(isUserExists(refAddr), "refUser doesn't exist");

        sendOnInsuranceAddr(0);
        lastUserId++;
        users[user].id = lastUserId;
        idToAddr[lastUserId] = user;
        users[user].ref = refAddr;
        emit Registration(user, refAddr, lastUserId, users[refAddr].id);
    }

    function buyNewLvl(uint256 lvl) public payable levelIsOpen(lvl) {
        if (!lvlIsAv[lvl])
            _openLevel(lvl);
        address user = msg.sender;
        uint256 _levelPrice = lvlPrice[lvl];
        if (users[user].Insurance[lvl])
            _levelPrice += ((_levelPrice * 5) / 100);

        require(isUserExists(user), "user doesn't exist");
        require(lvl > 0 && lvl <= lastLvl, "wrong level");
        require(!users[user].lvlIsAct[lvl], "level is already active");
        require(msg.value == _levelPrice, "wrong value");
        usersAtLvl[lvl]++;
        if (users[user].Insurance[lvl])
            sendOnInsuranceAddr(lvl);

        users[user].lvlIsAct[lvl] = true;
        users[user].lvlWasAct[lvl] = true;
        users[user].reinvests[lvl] = reinvCount[lvl];

        uint256 _lvlInRow;
        for (uint256 i = 1; i <= 15; i++) {
            if (users[user].lvlIsAct[i] == false)
                break;
            _lvlInRow = i;
        }
        users[user].lvlInRow = _lvlInRow;
        if (_lvlInRow > 8)
            users[user].extraBR = BRPercent[_lvlInRow];
        updateStructure(user, freeSecondLvl[lvl], lvl);
    }

    function buyNewLvlWI(uint256 lvl) external payable levelIsOpen(lvl) {
        require(!insuranceWasSent, "not available");
        users[msg.sender].Insurance[lvl] = true;
        if (IIds[msg.sender] == 0) {
            lastIUserId++;
            IAddrs[lastIUserId] = msg.sender;
            IIds[msg.sender] = lastIUserId;
        }
        IPayments[msg.sender] += (lvlPrice[lvl] * 20) / 100;
        buyNewLvl(lvl);
    }

    function setInsuranceAddress(address newInsAddr) external onlyOwner {
        owners[6] = newInsAddr;
    }

    function setMarkettingAddress(address newMarketingAddr) external onlyOwner {
        owners[7] = newMarketingAddr;
    }

    function setlevelStartTime(uint256 lvl, uint256 time) external onlyOwner {
        levelStartTime[lvl] = time;
    }

    function _openLevel(uint256 lvl) private {
        lvlIsAv[lvl] = true;
        expLvl[lvl] = true;
        refRewardsSendTime[lvl] = block.timestamp + 600;
    }

    function sendFreezedReferralRewards(uint256 lvl) external onlyOwner {
        require(block.timestamp >= refRewardsSendTime[lvl] && refRewardsSendTime[lvl] > 0, "not available");
        require(numOfFrzdRefSave[lvl] != 1, "all rewards was sent");
        expLvl[lvl] = false;
        if (nOfPA[lvl] > 0)
            sendFrzdRefRewInt(lvl);
    }

    function updateStructure(address user, uint256 StrId, uint256 lvl) private {
        users[user].place[lvl] = lvlToStr[lvl].idToStr[StrId].freePlace;
        users[user].AbsPlace[lvl] = lvlToStr[lvl].freeAbsPlace;
        users[user].usersBP[lvl] = usersBeforeFirstPandingCounter(user, lvl);

        lvlToStr[lvl].idToStr[StrId].secondStrLvl[(lvlToStr[lvl].idToStr[StrId].freePlace) - 6] = user;
        lvlToStr[lvl].idToStr[StrId].freePlace++;
        lvlToStr[lvl].freeAbsPlace++;
        sendRewards(user, StrId, lvl);
        emit NewUserPlace(
            user,
            StrId,
            lvl,
            users[user].place[lvl],
            users[user].Insurance[lvl]
        );
        if (lvlToStr[lvl].idToStr[StrId].freePlace == 12)
            upgradeStructure(StrId, lvl);
    }

    function upgradeStructure(uint256 StrId, uint256 lvl) private {
        for (uint256 i = 0; i < 4; i++) {
            address newMainStrLvl = lvlToStr[lvl].idToStr[StrId].firstStrLvl[i];
            uint256 newMatrixId = users[newMainStrLvl].AbsPlace[lvl];
            Structure memory structure = Structure({
                StrId: newMatrixId,
                mainStrLvl: newMainStrLvl,
                firstStrLvl: [address(0), address(0), address(0), address(0)],
                secondStrLvl: [address(0), address(0), address(0), address(0), address(0), address(0)],
                freePlace: 2
            });
            lvlToStr[lvl].idToStr[newMatrixId] = structure;
            users[newMainStrLvl].place[lvl] = 1;
        }

        address mainAddr = lvlToStr[lvl].idToStr[StrId].mainStrLvl;
        uint256 _freePlace = lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].freePlace;

        for (uint256 i = 0; i < 6; i++) {
            if (_freePlace > 5) {
                freeFirstLvl[lvl]++;
                _freePlace = lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].freePlace;
            }
            lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].firstStrLvl[_freePlace - 2] = lvlToStr[lvl].idToStr[StrId].secondStrLvl[i];
            users[lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].firstStrLvl[_freePlace - 2]
            ].place[lvl] = _freePlace;
            lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].freePlace++;
            _freePlace++;
        }

        if (users[mainAddr].id < 6) {
            if (_freePlace > 5) {
                freeFirstLvl[lvl]++;
                _freePlace = lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].freePlace;
            }
            lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].firstStrLvl[_freePlace - 2] = mainAddr;
            users[mainAddr].place[lvl] = _freePlace;
            users[mainAddr].AbsPlace[lvl] = lvlToStr[lvl].freeAbsPlace;
            lvlToStr[lvl].freeAbsPlace++;
            lvlToStr[lvl].idToStr[freeFirstLvl[lvl]].freePlace++;
            reinvCount[lvl]++;
        } else {
            users[mainAddr].lvlIsAct[lvl] = false;
            users[mainAddr].place[lvl] = 0;
            users[mainAddr].AbsPlace[lvl] = 0;
            uint256 _lvlInRow = users[mainAddr].lvlInRow;
            if (_lvlInRow > 8 && lvl <= _lvlInRow) {
                users[mainAddr].lvlInRow = lvl - 1;
                if (users[mainAddr].lvlInRow > 8)
                    users[mainAddr].extraBR = BRPercent[_lvlInRow];
                else 
                    users[mainAddr].extraBR = 0;
            }
        }
        freeSecondLvl[lvl]++;
    }

    function sendRewards(address user, uint256 StrId, uint256 lvl) private {
        address payable rec;
        if (users[user].place[lvl] == 11) {
            rec = payable(lvlToStr[lvl].idToStr[StrId].mainStrLvl);
            users[rec].usersBP[lvl] = 0;
        } else 
            if (users[user].place[lvl] == 8) {
                rec = payable(lvlToStr[lvl].idToStr[StrId].mainStrLvl);
                users[rec].usersBP[lvl] = 3;
            } else 
                if (users[user].place[lvl] < 8) 
                    rec = payable(lvlToStr[lvl].idToStr[StrId].firstStrLvl[users[user].place[lvl] - 6]);
                else
                    rec = payable(lvlToStr[lvl].idToStr[StrId].firstStrLvl[users[user].place[lvl] - 7]);

                if (users[rec].Insurance[lvl]) {
                    users[rec].Insurance[lvl] = false;
                    IPayments[rec] -= (lvlPrice[lvl] * 20) / 100;
                    if (IPayments[rec] == 0) {
                        IIds[IAddrs[lastIUserId]] = IIds[rec];
                        IAddrs[IIds[rec]] = IAddrs[lastIUserId];
                        IIds[rec] = 0;
                        lastIUserId--;
                    }
                }
                users[rec].usersBP[lvl] = usersBeforeSecondPandingCounter(rec, lvl);

        uint256 BR;
        if (users[rec].extraBR > 0)
            BR = users[rec].extraBR;
        else 
            BR = BRPercent[lvl];
        rec.transfer((lvlPrice[lvl] * BR) / 100);
        users[rec].gottenRewards[lvl] += (lvlPrice[lvl] * BR) / 100;

        if (expLvl[lvl] && refRewardsSendTime[lvl] > block.timestamp && refRewardsSendTime[lvl] > 0) {
            uint256 n = 1;
            address nextRef = user;
            while (n <= 7) {
                address _ref = users[nextRef].ref;
                if (users[_ref].lvlWasAct[lvl]) {
                    n++;
                    nextRef = _ref;
                } else
                    break; 
            }
            if (n == 8)
                sendRefRew(user, lvl);
            else {
                nOfPA[lvl]++;
                nOfPASave[lvl]++;
                pAddr[lvl][nOfPA[lvl]] = user;
                uint256 i = 1;
                address _nextReferrer = user;
                while (i <= 7) {
                    address _ref = users[_nextReferrer].ref;
                    if (users[_ref].lvlWasAct[lvl])
                        i++;
                    else
                        users[_ref].frzdRefReward[lvl] +=(lvlPrice[lvl] * refPercent[i])/100;
                    _nextReferrer = _ref;
                }
            }
        } else
            sendRefRew(user, lvl);

        address payable _marketing = payable(owners[7]);
        uint256 marketingPercent = (77 - BR);
        _marketing.transfer((lvlPrice[lvl] * marketingPercent) / 100);
    }

    function sendRefRew(address user, uint256 lvl) private {
        address nextRef = user;
        uint256 j = 1;
        while (j <= 7) {
            address payable _ref = payable(users[nextRef].ref);
            if (users[_ref].lvlWasAct[lvl]) {
                _ref.transfer((lvlPrice[lvl] * refPercent[j]) / 100);
                users[_ref].gottenRefReward[lvl] += (lvlPrice[lvl] * refPercent[j])/100;
                j++;
            } else
                users[_ref].lostMoney[lvl] += (lvlPrice[lvl] * refPercent[j])/100;

            nextRef = _ref;
        }
    }

    function countFrzdRefRew(uint256 lvl) external onlyOwner {
        require(block.timestamp >= refRewardsSendTime[lvl] && refRewardsSendTime[lvl] > 0, "not available");
        uint256 num1;
        uint256 num2;
        if ((nOfPA[lvl]/200) > 0) {
            nOfPA[lvl] -= 200;
            num1 = nOfPASave[lvl] - nOfPA[lvl];
            num2 = 199;
        } else {
            num1 = nOfPASave[lvl];
            num2 = nOfPA[lvl] - 1;
        }
        for (uint256 i = num1 - num2; i <= num1; i++) {
            address nextRef = pAddr[lvl][i];
            uint256 j = 1;
            while (j <= 7) {
                address payable _ref = payable(users[nextRef].ref);
                users[_ref].frzdRefReward[lvl] = 0;
                if (users[_ref].lvlWasAct[lvl]) {
                    if (wRR[lvl][_ref] == 0) {
                        numOfFrzdRef[lvl]++;
                        wRRAddr[lvl][numOfFrzdRef[lvl]] = _ref;
                    }
                    wRR[lvl][_ref] += (lvlPrice[lvl] * refPercent[j])/100;
                    j++;
                } else
                    users[_ref].lostMoney[lvl] += (lvlPrice[lvl] * refPercent[j])/100;
                nextRef = _ref;
            }
        }
        numOfFrzdRefSave[lvl] = numOfFrzdRef[lvl];
    }

    function sendFrzdRefRewInt(uint256 lvl) private {
        uint256 num1;
        uint256 num2;
        if ((numOfFrzdRef[lvl]/200) > 0) {
            numOfFrzdRef[lvl] -= 200;
            num1 = numOfFrzdRefSave[lvl] - numOfFrzdRef[lvl];
            num2 = 199;
        } else {
            num1 = numOfFrzdRefSave[lvl];
            num2 = numOfFrzdRef[lvl] - 1;
            numOfFrzdRefSave[lvl] = 1;
        }
        for (uint256 i = num1 - num2; i <= num1; i++) {
            address payable rec = payable(wRRAddr[lvl][i]);
            uint256 amount = wRR[lvl][rec];
            users[rec].gottenRefReward[lvl] += amount;
            rec.transfer(amount);
        }
    }

    function sendOnInsuranceAddr(uint256 lvl) private {
        address payable rec = payable(owners[6]);
        if (lvl == 0)
            rec.transfer(registrationCost);
        else
            rec.transfer((lvlPrice[lvl] * 5) / 100);
    }

    function writeIData() external onlyOwner {
        uint256 num1;
        uint256 num2;
        if (lastIUserIdSave == 0)
            lastIUserIdSave = lastIUserId;
        if ((lastIUserId / 200) > 0) {
            lastIUserId -= 200;
            num1 = lastIUserIdSave - lastIUserId;
            num2 = 199;
        } else {
            num1 = lastIUserIdSave;
            num2 = lastIUserId - 1;
            insuranceWasSent = true;
        }
        for (uint256 i = num1 - num2; i <= num1; i++) {
            writeIDataInt(IPayments[IAddrs[i]], IAddrs[i]);
        }
    }

    function getNumOfIAddr() external view onlyOwner returns (uint256 _numOfIAddr) {
        return (lastIUserId);
    }

    function getNumOfRefAddr(uint256 lvl) external view onlyOwner returns (uint256 _numOfRefAddr) {
        return (nOfPASave[lvl]);
    }

    function writeIDataInt(uint256 Ipayment, address Iaddress) private {
        (bool success, bytes memory data) = owners[6].call(abi.encodeWithSignature("writeInsuranceDates(uint256,address)", Ipayment, Iaddress));
    }

    function paymentOfInsurance() external onlyOwner {
        (bool success, bytes memory data) = owners[6].call(abi.encodeWithSignature("payment()"));
    }

    function getNumOfFrzdRef(uint256 lvl)
        external
        view
        onlyOwner
        returns (uint256 quantityOfFrzdRef)
    {
        return (numOfFrzdRefSave[lvl]);
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function usersBeforeFirstPandingCounter(address user, uint256 lvl) private view returns (uint256) {
        uint256 n = users[user].AbsPlace[lvl];
        if (n % 2 == 0) 
            return (((n - 4) / 2) + 5 + reinvCount[lvl] + (reinvCount[lvl] / 2));
        else 
            return (((n - 5) / 2) + 5 + reinvCount[lvl] + ((reinvCount[lvl] + 1) / 2));
        
    }

    function usersBeforeSecondPandingCounter(address user, uint256 lvl) private view returns (uint256) {
        return (6 * (users[user].AbsPlace[lvl] - lvlToStr[lvl].idToStr[freeSecondLvl[lvl]].StrId - 1) + 15 - lvlToStr[lvl].idToStr[freeSecondLvl[lvl]].freePlace);
    }

    function availableLevels() external view onlyOwner returns (bool[16] memory) {
        return (lvlIsAv);
    }

    function getlevelPrices() external view onlyOwner returns (uint256[16] memory levelPrices) {
        uint256[16] memory _levelPrices;
        for (uint256 i = 1; i < 16; i++) {
            _levelPrices[i] = lvlPrice[i];
        }
        return (_levelPrices);
    }

    function userSiteDataes(address user) external view onlyOwner
        returns (
            uint256 extraBR,
            uint256[16] memory lostMoney,
            bool[16] memory levelWasActivated,
            bool[16] memory levelIsActive,
            uint256[16] memory usersBP,
            bool[16] memory insurance,
            uint256[16] memory userRewards,
            uint256[16] memory userReferralRewards
        ) {
        address ad = user;
        uint256[16] memory _lostMoney;
        bool[16] memory _levelWasActivated;
        bool[16] memory _levelIsActive;
        uint256[16] memory _usersBeforePayment;
        bool[16] memory _insurance;
        uint256[16] memory _userRewards;
        uint256[16] memory _userReferralRewards;
        for (uint256 i = 1; i < 16; i++) {
            _lostMoney[i] = users[ad].lostMoney[i];
            _levelWasActivated[i] = users[ad].lvlWasAct[i];
            _levelIsActive[i] = users[ad].lvlIsAct[i];
            _usersBeforePayment[i] = users[ad].usersBP[i];
            _insurance[i] = users[ad].Insurance[i];
            _userRewards[i] = users[ad].gottenRewards[i];
            _userReferralRewards[i] = users[ad].gottenRefReward[i];
        }
        return (
            users[ad].extraBR,
            _lostMoney,
            _levelWasActivated,
            _levelIsActive,
            _usersBeforePayment,
            _insurance,
            _userRewards,
            _userReferralRewards
        );
    }

    function userSiteDatesTwo(address user) external view onlyOwner returns (uint256[16] memory freezedReferralReward) {
        uint256[16] memory _freezedReferralReward;
        for (uint256 i = 1; i < 16; i++) {
            _freezedReferralReward[i] = users[user].frzdRefReward[i];
        }
        return (_freezedReferralReward);
    }

    function levelStartTimeDates() external view onlyOwner returns (uint256[16] memory levelsStartTime) {
        uint256[16] memory _levelStartTime;
        for (uint256 i = 1; i < 16; i++) {
            _levelStartTime[i] = levelStartTime[i];
        }
        return (_levelStartTime);
    }

    function paymentProgressDates(address user) external view onlyOwner returns (uint256[16] memory userAbsolutePlace, uint256[16] memory reinvest) {
        uint256[16] memory _userAbsolutePlace;
        uint256[16] memory _reinvest;
        for (uint256 i = 1; i < 16; i++) {
            _userAbsolutePlace[i] = users[user].AbsPlace[i];
            _reinvest[i] = users[user].reinvests[i];
        }
        return (_userAbsolutePlace, _reinvest);
    }

    function userAtLevelDates() external view onlyOwner returns (uint256[16] memory usersAtTheLevel) {
        uint256[16] memory _usersAtLvl;
        for (uint256 i = 1; i < 16; i++) {
            _usersAtLvl[i] = usersAtLvl[i];
        }
        return (_usersAtLvl);
    }

    function serValues() private {
        BRPercent[1] = 60;
        BRPercent[2] = 60;
        BRPercent[3] = 60;
        BRPercent[4] = 60;
        BRPercent[5] = 60;
        BRPercent[6] = 60;
        BRPercent[7] = 60;
        BRPercent[8] = 60;
        BRPercent[9] = 61;
        BRPercent[10] = 63;
        BRPercent[11] = 66;
        BRPercent[12] = 69;
        BRPercent[13] = 72;
        BRPercent[14] = 76;
        BRPercent[15] = 77;

        refPercent[1] = 8;
        refPercent[2] = 5;
        refPercent[3] = 3;
        refPercent[4] = 2;
        refPercent[5] = 2;
        refPercent[6] = 2;
        refPercent[7] = 1;

        lvlPrice[1] = 140000000000000000 wei;
        lvlPrice[2] = 180000000000000000 wei;
        lvlPrice[3] = 250000000000000000 wei;
        lvlPrice[4] = 360000000000000000 wei;
        lvlPrice[5] = 500000000000000000 wei;
        lvlPrice[6] = 650000000000000000 wei;
        lvlPrice[7] = 900000000000000000 wei;
        lvlPrice[8] = 1250000000000000000 wei;
        lvlPrice[9] = 1800000000000000000 wei;
        lvlPrice[10] = 2700000000000000000 wei;
        lvlPrice[11] = 4000000000000000000 wei;
        lvlPrice[12] = 6300000000000000000 wei;
        lvlPrice[13] = 10000000000000000000 wei;
        lvlPrice[14] = 15000000000000000000 wei;
        lvlPrice[15] = 22000000000000000000 wei;

        for (uint256 i = 1; i <= lastLvl; i++) {
            freeSecondLvl[i] = 1;
            freeFirstLvl[i] = 2;
        }
    }
}
