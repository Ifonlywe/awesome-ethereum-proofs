// Submitted by EthereumHistory (ethereumhistory.com)
//
// Elcoin (ELC) — main token contract.
// Address: 0xa04bf47f0e9d1745d254b9b89f304c7d7ad121aa
// Deployed: 2016-01-27 by 0x48175Da4c20313bcb6B62d74937d3fF985885701
// Compiler: solc 0.1.x family (with Ambisafe-internal optimizer pass)
//
// Source-reconstruction notes:
//   This Elcoin is from Jan 2016, four months before the version in the
//   public GitHub repo (ElcoinCurrency/ElcoinContract, May 2016). The
//   January source is NOT in the repo. This reconstruction is derived
//   from the decompiled bytecode plus the May-2016 source as a guide.
//
//   Key differences from the May-2016 source:
//     - Ambi v1 interface used: getChildCount(bytes32,bytes32) +
//       getChildAddress(bytes32,bytes32,uint8) for role iteration,
//       instead of the later hasRelation(bytes32,bytes32,address).
//     - State variable is `Ambi public ambi` (selector 0x3751707c),
//       not the inherited `Ambi ambiC` from AmbiEnabled.
//     - Allowances are stored as a struct[] (`allowances`) with a
//       hash-keyed index mapping `allowanceIndex(bytes32)` rather
//       than the standard mapping(address=>mapping(address=>uint)).
//     - Five custom approval/transfer functions not in the May source:
//       approveTo, unapproveTo, approveAllowance, transferTo,
//       allowanceTotal, getAccountBalance.
//     - No PoT integration ("elcoinPoT" is not referenced).
//     - No treasury / gas-refund infrastructure (those were added later).
//     - `remove()` uses a hardcoded `msg.sender == address(ambi)` check
//       instead of the later checkAccess("owner") modifier.
//
// Roles used (verified by PUSH-instruction frequency in bytecode):
//   "security"      PUSH8  × 7 — approve, unapprove, approveTo,
//                                unapproveTo, transferTo, transferFrom,
//                                transfer
//   "currencyOwner" PUSH13 × 4 — issueCoin, setFeeAddr, batchTransfer,
//                                approveAllowance (encoded as
//                                PUSH13 0x31bab93932b731bca7bbb732b9
//                                × 2^153, an Ambisafe-internal solc
//                                optimizer trick: this byte-pattern
//                                does NOT appear in any standard solc
//                                0.1.x/0.2.x/0.3.x output we tested)
//   "pool"          PUSH32 × 1 — transferPool
//   "cron"          PUSH32 × 1 — setFee
//
// The Ambi contract is at 0xa95b9127e7102dcfa3869c47ee12a0ec85c261c5,
// deployed 45 minutes earlier by the same EOA.

contract Ambi {
    function getNodeAddress(bytes32 _name) constant returns (address);
    function addNode(bytes32 _name, address _addr) external returns (bool);
    function getChildCount(bytes32 _name, bytes32 _role) constant returns (uint);
    function getChildAddress(bytes32 _name, bytes32 _role, uint8 _idx) constant returns (address);
}

contract PosRewards {
    function transfer(address _from, address _to, uint _value);
}

contract ElcoinDb {
    function getBalance(address addr) constant returns(uint balance);
    function deposit(address addr, uint amount, bytes32 hash, uint time) returns (bool res);
    function withdraw(address addr, uint amount, bytes32 hash, uint time) returns (bool res);
}

contract MetaCoinInterface {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approved(address indexed _owner, address indexed _spender, uint256 _value);
    event Unapproved(address indexed _owner, address indexed _spender);

    function totalSupply() constant returns (uint256 supply){}
    function balanceOf(address _owner) constant returns (uint256 balance){}
    function transfer(address _to, uint256 _value) returns (bool success){}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){}
    function approve(address _spender, uint256 _value) returns (bool success){}
    function unapprove(address _spender) returns (bool success){}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining){}
}

contract Elcoin is MetaCoinInterface {
    Ambi public ambi;
    bytes32 public name;

    event Error(uint8 indexed code, address indexed origin, address indexed sender);

    mapping (address => uint) public recoveredIndex;
    address[] public recovered;

    uint public totalSupply;
    uint public absMinFee;
    uint public feePercent;
    uint public absMaxFee;
    address public feeAddr;

    mapping (bytes32 => uint) public allowanceIndex;
    struct Allowance {
        address owner;
        address spender;
        uint amount;
    }
    Allowance[] public allowances;

    modifier checkAccess(bytes32 _role) {
        if (address(ambi) != 0x0) {
            uint8 count = uint8(ambi.getChildCount(name, _role));
            for (uint8 j = 1; j <= count; j++) {
                if (ambi.getChildAddress(name, _role, j) == msg.sender) {
                    _
                }
            }
        }
    }

    function Elcoin() {
        recovered.length++;
        feeAddr = tx.origin;
        allowances.length++;
    }

    function _db() internal constant returns (ElcoinDb) {
        return ElcoinDb(ambi.getNodeAddress("elcoinDb"));
    }

    function getAddress(bytes32 _name) constant returns (address) {
        return ambi.getNodeAddress(_name);
    }

    function setAmbiAddress(address _ambi, bytes32 _name) returns (bool) {
        if (address(ambi) != 0x0) {
            if (_ambi != address(ambi)) {
                return false;
            }
        }
        Ambi ambiContract = Ambi(_ambi);
        if (ambiContract.getNodeAddress(_name) != address(this)) {
            bool isNode = ambiContract.addNode(_name, address(this));
            if (!isNode) {
                return false;
            }
        }
        name = _name;
        ambi = ambiContract;
        return true;
    }

    function remove() {
        if (msg.sender != address(ambi)) {
            return;
        }
        suicide(address(ambi));
    }

    function balanceOf(address _account) constant returns (uint) {
        return _db().getBalance(_account);
    }

    function getAccountBalance(address _account) constant returns (uint) {
        return _db().getBalance(_account);
    }

    function calculateFee(uint _amount) constant returns (uint) {
        uint fee = (_amount / 100) * feePercent;
        if (fee < absMinFee) {
            return absMinFee;
        }
        if (fee > absMaxFee) {
            return absMaxFee;
        }
        return fee;
    }

    function _rawTransfer(ElcoinDb _db, address _from, address _to, uint _value) internal {
        _db.withdraw(_from, _value, 0, 0);
        uint fee = calculateFee(_value);
        uint net = _value - fee;
        _db.deposit(_to, net, 0, 0);

        Transfer(_from, _to, _value);
        if (fee > 0) {
            _db.deposit(feeAddr, fee, 0, 0);
        }
    }

    function _transfer(ElcoinDb _db, address _from, address _to, uint _value) internal returns (bool) {
        if (recoveredIndex[_from] != 0) {
            return false;
        }
        if (_value < absMinFee) {
            return false;
        }
        uint balance = _db.getBalance(_from);
        if (balance < _value) {
            return false;
        }
        _rawTransfer(_db, _from, _to, _value);
        return true;
    }

    function _transferWithReward(ElcoinDb _db, address _from, address _to, uint _value) internal returns (bool) {
        if (!_transfer(_db, _from, _to, _value)) {
            Error(2, tx.origin, msg.sender);
            return false;
        }
        address pos = getAddress("elcoinPoS");
        if (pos != 0x0) {
            PosRewards(pos).transfer(_from, _to, _value);
        }
        return true;
    }

    function issueCoin(address _to, uint _value) checkAccess("currencyOwner") returns (bool) {
        if (totalSupply > 0) {
            Error(6, tx.origin, msg.sender);
            return false;
        }
        if (_value == 0) {
            totalSupply = 200000000000000;
            return true;
        }
        bool dep = _db().deposit(_to, _value, 0, 0);
        totalSupply = _value;
        return dep;
    }

    function batchTransfer(address[] _to, uint[] _value) checkAccess("currencyOwner") returns (bool) {
        if (_to.length != _value.length) {
            Error(7, tx.origin, msg.sender);
            return false;
        }
        uint totalToSend = 0;
        for (uint8 i = 0; i < _value.length; i++) {
            totalToSend += _value[i];
        }
        ElcoinDb db = _db();
        if (db.getBalance(tx.origin) < totalToSend) {
            Error(8, tx.origin, msg.sender);
            return false;
        }
        for (uint8 j = 0; j < _to.length; j++) {
            db.withdraw(tx.origin, _value[j], 0, 0);
            uint fee = calculateFee(_value[j]);
            db.deposit(_to[j], _value[j] - fee, 0, 0);
            Transfer(tx.origin, _to[j], _value[j]);
            if (fee > 0) {
                db.deposit(feeAddr, fee, 0, 0);
            }
        }
        return true;
    }

    function transfer(address _to, uint _value) checkAccess("security") returns (bool) {
        return _transferWithReward(_db(), tx.origin, _to, _value);
    }

    function transferTo(address _from, address _to, uint _value) checkAccess("security") returns (bool) {
        if (_from != tx.origin) {
            Error(9, tx.origin, msg.sender);
            return false;
        }
        if (_from != msg.sender) {
            Error(9, tx.origin, msg.sender);
            return false;
        }
        return _transferWithReward(_db(), _from, _to, _value);
    }

    function transferPool(address _from, address _to, uint _value) checkAccess("pool") returns (bool) {
        return _transferWithReward(_db(), _from, _to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) checkAccess("security") returns (bool) {
        bytes32 hashKey = sha3(_from, _to);
        uint idx = allowanceIndex[hashKey];
        if (idx == 0) {
            Error(12, tx.origin, msg.sender);
            return false;
        }
        if (_value > allowances[idx].amount) {
            Error(13, tx.origin, msg.sender);
            return false;
        }
        allowances[idx].amount -= _value;
        ElcoinDb db = _db();
        address pos = getAddress("elcoinPoS");
        if (!_transferWithReward(db, _from, _to, _value)) {
            allowances[idx].amount += _value;
            return false;
        }
        return true;
    }

    function approve(address _spender, uint _value) checkAccess("security") returns (bool) {
        if (tx.origin == _spender) {
            Error(3, tx.origin, msg.sender);
            return false;
        }
        if (_value < absMinFee) {
            Error(3, tx.origin, msg.sender);
            return false;
        }
        bytes32 hashKey = sha3(tx.origin, _spender);
        if (allowanceIndex[hashKey] != 0) {
            allowances[allowanceIndex[hashKey]].amount += _value;
        } else {
            allowances.length++;
            allowances[allowances.length - 1].owner = tx.origin;
            allowances[allowances.length - 1].spender = _spender;
            allowances[allowances.length - 1].amount = _value;
            allowanceIndex[hashKey] = allowances.length - 1;
        }
        Approved(tx.origin, _spender, _value);
        return true;
    }

    function approveTo(address _from, address _to, uint _value) checkAccess("security") returns (bool) {
        if (_from != tx.origin) {
            Error(10, tx.origin, msg.sender);
            return false;
        }
        if (_from != msg.sender) {
            Error(10, tx.origin, msg.sender);
            return false;
        }
        if (_from == _to) {
            Error(3, tx.origin, msg.sender);
            return false;
        }
        if (_value < absMinFee) {
            Error(3, tx.origin, msg.sender);
            return false;
        }
        bytes32 hashKey = sha3(_from, _to);
        if (allowanceIndex[hashKey] != 0) {
            allowances[allowanceIndex[hashKey]].amount += _value;
        } else {
            allowances.length++;
            allowances[allowances.length - 1].owner = _from;
            allowances[allowances.length - 1].spender = _to;
            allowances[allowances.length - 1].amount = _value;
            allowanceIndex[hashKey] = allowances.length - 1;
        }
        Approved(_from, _to, _value);
        return true;
    }

    function approveAllowance(address _from, address _to, uint _value) checkAccess("currencyOwner") returns (bool) {
        if (_from == _to) {
            Error(3, tx.origin, msg.sender);
            return false;
        }
        if (_value < absMinFee) {
            Error(3, tx.origin, msg.sender);
            return false;
        }
        bytes32 hashKey = sha3(_from, _to);
        if (allowanceIndex[hashKey] != 0) {
            allowances[allowanceIndex[hashKey]].amount += _value;
        } else {
            allowances.length++;
            allowances[allowances.length - 1].owner = _from;
            allowances[allowances.length - 1].spender = _to;
            allowances[allowances.length - 1].amount = _value;
            allowanceIndex[hashKey] = allowances.length - 1;
        }
        Approved(_from, _to, _value);
        return true;
    }

    function unapprove(address _spender) checkAccess("security") returns (bool) {
        bytes32 hashKey = sha3(tx.origin, _spender);
        if (allowanceIndex[hashKey] < 1) {
            Error(4, tx.origin, msg.sender);
            return false;
        }
        uint idx = allowanceIndex[hashKey];
        allowanceIndex[hashKey] = 0;
        uint last = allowances.length - 1;
        if (idx + 1 < allowances.length) {
            bytes32 lastKey = sha3(allowances[last].owner, allowances[last].spender);
            allowanceIndex[lastKey] = idx;
            allowances[idx] = allowances[last];
        }
        delete allowances[last];
        allowances.length--;
        Unapproved(tx.origin, _spender);
        return true;
    }

    function unapproveTo(address _from, address _to) checkAccess("security") returns (bool) {
        if (_from != tx.origin) {
            Error(11, tx.origin, msg.sender);
            return false;
        }
        if (_from != msg.sender) {
            Error(11, tx.origin, msg.sender);
            return false;
        }
        bytes32 hashKey = sha3(_from, _to);
        if (allowanceIndex[hashKey] < 1) {
            Error(4, tx.origin, msg.sender);
            return false;
        }
        uint idx = allowanceIndex[hashKey];
        allowanceIndex[hashKey] = 0;
        uint last = allowances.length - 1;
        if (idx + 1 < allowances.length) {
            bytes32 lastKey = sha3(allowances[last].owner, allowances[last].spender);
            allowanceIndex[lastKey] = idx;
            allowances[idx] = allowances[last];
        }
        delete allowances[last];
        allowances.length--;
        Unapproved(_from, _to);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        bytes32 hashKey = sha3(_owner, _spender);
        if (allowanceIndex[hashKey] == 0) {
            return 0;
        }
        return allowances[allowanceIndex[hashKey]].amount;
    }

    function allowanceTotal(address _owner) constant returns (uint) {
        uint total = 0;
        for (uint i = 1; i < allowances.length; i++) {
            if (allowances[i].owner == _owner) {
                total += allowances[i].amount;
            }
        }
        return total;
    }

    function setFeeAddr(address _feeAddr) checkAccess("currencyOwner") {
        feeAddr = _feeAddr;
    }

    function setFee(uint _absMinFee, uint _feePercent, uint _absMaxFee) checkAccess("cron") returns (bool) {
        if (_absMinFee < 0 || _feePercent < 0 || _feePercent > 100 || _absMaxFee < 0 || _absMaxFee < _absMinFee) {
            Error(1, tx.origin, msg.sender);
            return false;
        }
        absMinFee = _absMinFee;
        feePercent = _feePercent;
        absMaxFee = _absMaxFee;
        return true;
    }
}
