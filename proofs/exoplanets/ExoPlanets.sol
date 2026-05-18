// Submitted by EthereumHistory (ethereumhistory.com)
pragma solidity ^0.4.18;


contract ExoPlanets {

  using SafeMath for uint256;

  /*** EVENTS ***/
  event Birth(uint256 indexed tokenId, string name, uint32 lifeRate, address owner);
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);
  event Transfer(address from, address to, uint256 tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ContractUpgrade(address newContract);

  /*** CONSTANTS ***/
  string public constant NAME = "ExoPlanets";
  string public constant SYMBOL = "XPL";
  string public constant BASE_URL = "https://exoplanets.io/metadata/planet_";

  uint256 private constant PROMO_CREATION_LIMIT = 4700;

  /*** STORAGE ***/

  // slot 0: ownerOf (public mapping named currentOwner for auto-getter)
  mapping (uint256 => address) public currentOwner;
  // slot 1: balanceOf
  mapping (address => uint256) private ownershipTokenCount;
  // slot 2: approvedToTransfer
  mapping (uint256 => address) public approvedToTransfer;
  // slot 3: priceOf
  mapping (uint256 => uint256) private exoplanetIndexToPrice;

  // slot 4: ceoAddress
  address public ceoAddress;
  // slot 5: cooAddress (packed with inPresaleMode at byte 20 and paused at byte 21)
  address public cooAddress;
  bool public inPresaleMode;
  bool public paused;
  // slot 6: newContractAddress
  address public newContractAddress;

  /*** DATATYPES ***/
  struct Exoplanet {
    uint8 lifeRate;
    uint32 priceInExoTokens;
    uint32 numOfTokensBonusOnPurchase;
    string name;
    string cryptoMatch;
    string techBonus1;
    string techBonus2;
    string techBonus3;
    string scientificData;
  }

  // slot 7: exoplanets array
  Exoplanet[] private exoplanets;

  /*** ACCESS MODIFIERS ***/
  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }

  modifier onlyCLevel() {
    require(
      msg.sender == ceoAddress ||
      msg.sender == cooAddress
    );
    _;
  }

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  modifier whenNotInPresale() {
    require(!inPresaleMode);
    _;
  }

  modifier whenInPresale() {
    require(inPresaleMode);
    _;
  }

  /*** CONSTRUCTOR ***/
  function ExoPlanets() public {
    inPresaleMode = true;
    paused = false;
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
  }

  /*** PUBLIC FUNCTIONS ***/
  function approve(address _to, uint256 _tokenId) public {
    require(_owns(msg.sender, _tokenId));
    approvedToTransfer[_tokenId] = _to;
    Approval(msg.sender, _to, _tokenId);
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownershipTokenCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address owner) {
    return currentOwner[_tokenId];
  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    return exoplanetIndexToPrice[_tokenId];
  }

  function createContractExoplanet(
    string _name,
    uint256 _initialPrice,
    uint32 _priceInExoTokens,
    string _cryptoMatch,
    uint32 _numOfTokensBonusOnPurchase,
    uint8 _lifeRate,
    string _scientificData
  ) public onlyCLevel {
    _createExoplanet(_name, address(this), _initialPrice, _priceInExoTokens, _cryptoMatch, _numOfTokensBonusOnPurchase, _lifeRate, _scientificData);
  }

  function transferUnownedPlanet(address _to, uint256 _tokenId) public onlyCLevel {
    require(currentOwner[_tokenId] == address(this));
    require(_to != address(0));
    _transfer(currentOwner[_tokenId], _to, _tokenId);
    TokenSold(_tokenId, exoplanetIndexToPrice[_tokenId], exoplanetIndexToPrice[_tokenId], address(this), _to, exoplanets[_tokenId].name);
  }

  function getExoplanet(uint256 _tokenId) public view returns (
    string exoName,
    uint256 sellingPrice,
    address _currentOwner,
    uint8 lifeRate,
    uint32 priceInExoTokens,
    uint32 numOfTokensBonusOnPurchase,
    string cryptoMatch,
    string scientificData
  ) {
    Exoplanet storage planet = exoplanets[_tokenId];
    exoName = planet.name;
    lifeRate = planet.lifeRate;
    priceInExoTokens = planet.priceInExoTokens;
    numOfTokensBonusOnPurchase = planet.numOfTokensBonusOnPurchase;
    cryptoMatch = planet.cryptoMatch;
    scientificData = planet.scientificData;
    sellingPrice = exoplanetIndexToPrice[_tokenId];
    _currentOwner = currentOwner[_tokenId];
  }

  function getName(uint256 _tokenId) public view returns (string) {
    return exoplanets[_tokenId].name;
  }

  function getCryptoMatch(uint256 _tokenId) public view returns (string) {
    return exoplanets[_tokenId].cryptoMatch;
  }

  function getLifeRate(uint256 _tokenId) public view returns (uint8) {
    return exoplanets[_tokenId].lifeRate;
  }

  function getScientificData(uint256 _tokenId) public view returns (string) {
    return exoplanets[_tokenId].scientificData;
  }

  function getPriceInExoTokens(uint256 _tokenId) public view returns (uint32) {
    return exoplanets[_tokenId].priceInExoTokens;
  }

  function getNumOfTokensBonusOnPurchase(uint256 _tokenId) public view returns (uint32) {
    return exoplanets[_tokenId].numOfTokensBonusOnPurchase;
  }

  function getTechBonus1(uint256 _tokenId) public view returns (string) {
    return exoplanets[_tokenId].techBonus1;
  }

  function getTechBonus2(uint256 _tokenId) public view returns (string) {
    return exoplanets[_tokenId].techBonus2;
  }

  function getTechBonus3(uint256 _tokenId) public view returns (string) {
    return exoplanets[_tokenId].techBonus3;
  }

  function setPriceInEth(uint256 _tokenId, uint256 _newPrice) public whenNotInPresale {
    require(_owns(msg.sender, _tokenId));
    exoplanetIndexToPrice[_tokenId] = _newPrice;
  }

  function setPriceInExoTokens(uint256 _tokenId, uint32 _newPrice) public whenNotInPresale {
    require(_owns(msg.sender, _tokenId));
    exoplanets[_tokenId].priceInExoTokens = _newPrice;
  }

  function setScientificData(uint256 _tokenId, string _scientificData) public onlyCLevel {
    exoplanets[_tokenId].scientificData = _scientificData;
  }

  function setTechBonus1(uint256 _tokenId, string _techBonus1) public {
    require(_owns(msg.sender, _tokenId));
    exoplanets[_tokenId].techBonus1 = _techBonus1;
  }

  function setTechBonus2(uint256 _tokenId, string _techBonus2) public {
    require(_owns(msg.sender, _tokenId));
    exoplanets[_tokenId].techBonus2 = _techBonus2;
  }

  function setTechBonus3(uint256 _tokenId, string _techBonus3) public {
    require(_owns(msg.sender, _tokenId));
    exoplanets[_tokenId].techBonus3 = _techBonus3;
  }

  function setPresaleMode(bool _presaleMode) public onlyCEO {
    inPresaleMode = _presaleMode;
  }

  function pause() public onlyCEO whenNotPaused {
    paused = true;
  }

  function unpause() public onlyCEO whenPaused {
    paused = false;
  }

  function setNewAddress(address _v2Address) public onlyCEO whenPaused {
    newContractAddress = _v2Address;
    ContractUpgrade(_v2Address);
  }

  function tokenURI(uint256 _tokenId) public view returns (string) {
    return strConcat(BASE_URL, _tokenId);
  }

  function implementsERC721() public pure returns (bool) {
    return true;
  }

  function name() public pure returns (string) {
    return NAME;
  }

  function symbol() public pure returns (string) {
    return SYMBOL;
  }

  function payout() public onlyCLevel {
    ceoAddress.transfer(this.balance);
  }

  function payoutPartial(uint256 _amount) public onlyCLevel {
    require(_amount <= this.balance);
    ceoAddress.transfer(_amount);
  }

  function purchase(uint256 _tokenId) public payable whenNotPaused whenInPresale {
    uint256 sellingPrice;
    uint256 purchaseExcess;
    uint256 fee;
    uint256 multiplier;
    uint256 payment;
    address oldOwner;

    require(currentOwner[_tokenId] != msg.sender);
    require(_addressNotNull(msg.sender));

    sellingPrice = exoplanetIndexToPrice[_tokenId];
    require(msg.value >= sellingPrice);

    purchaseExcess = msg.value.sub(sellingPrice);

    if (sellingPrice <= 5 ether) {
      fee = 93; multiplier = 200;
    } else if (sellingPrice <= 10 ether) {
      fee = 93; multiplier = 150;
    } else if (sellingPrice <= 26 ether) {
      fee = 93; multiplier = 135;
    } else if (sellingPrice <= 36 ether) {
      fee = 94; multiplier = 125;
    } else if (sellingPrice <= 47 ether) {
      fee = 94; multiplier = 119;
    } else if (sellingPrice <= 59 ether) {
      fee = 95; multiplier = 117;
    } else if (sellingPrice <= 67.85 ether) {
      fee = 95; multiplier = 115;
    } else if (sellingPrice <= 76.67 ether) {
      fee = 95; multiplier = 113;
    } else {
      fee = 96; multiplier = 110;
    }

    exoplanetIndexToPrice[_tokenId] = sellingPrice.mul(multiplier).div(100);
    payment = sellingPrice.mul(fee).div(100);

    oldOwner = currentOwner[_tokenId];

    if (oldOwner != address(this)) {
      oldOwner.transfer(payment);
    }

    _transfer(oldOwner, msg.sender, _tokenId);

    TokenSold(_tokenId, sellingPrice, exoplanetIndexToPrice[_tokenId], oldOwner, msg.sender, exoplanets[_tokenId].name);

    msg.sender.transfer(purchaseExcess);
  }

  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));
    ceoAddress = _newCEO;
  }

  function setCOO(address _newCOO) public onlyCEO {
    require(_newCOO != address(0));
    cooAddress = _newCOO;
  }

  function takeOwnership(uint256 _tokenId) public whenNotPaused {
    require(_addressNotNull(msg.sender));
    require(_approved(msg.sender, _tokenId));
    _transfer(currentOwner[_tokenId], msg.sender, _tokenId);
  }

  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalExoplanets = totalSupply();
      uint256 resultIndex = 0;

      uint256 planetId;
      for (planetId = 0; planetId <= totalExoplanets; planetId++) {
        if (currentOwner[planetId] == _owner) {
          result[resultIndex] = planetId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  function totalSupply() public view returns (uint256 total) {
    return exoplanets.length;
  }

  function transfer(address _to, uint256 _tokenId) public whenNotPaused {
    require(_owns(msg.sender, _tokenId));
    require(_addressNotNull(_to));
    _transfer(msg.sender, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
    require(_approved(_from, _tokenId));
    require(_addressNotNull(_to));
    _transfer(_from, _to, _tokenId);
  }

  /*** PRIVATE FUNCTIONS ***/
  function _addressNotNull(address _to) private pure returns (bool) {
    return _to != address(0);
  }

  function _approved(address _to, uint256 _tokenId) private view returns (bool) {
    return approvedToTransfer[_tokenId] == _to;
  }

  function _createExoplanet(
    string _name,
    address _owner,
    uint256 _price,
    uint32 _priceInExoTokens,
    string _cryptoMatch,
    uint32 _numOfTokensBonusOnPurchase,
    uint8 _lifeRate,
    string _scientificData
  ) private {
    require(totalSupply() < uint256(uint32(PROMO_CREATION_LIMIT)));

    Exoplanet memory _exoplanet = Exoplanet(_lifeRate, _priceInExoTokens, _numOfTokensBonusOnPurchase, _name, _cryptoMatch, "", "", "", _scientificData);
    uint256 newPlanetId = exoplanets.push(_exoplanet) - 1;

    require(newPlanetId == uint256(uint32(newPlanetId)));

    Birth(newPlanetId, _name, _numOfTokensBonusOnPurchase, _owner);

    exoplanetIndexToPrice[newPlanetId] = _price;

    _transfer(address(0), _owner, newPlanetId);
  }

  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == currentOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownershipTokenCount[_to]++;
    currentOwner[_tokenId] = _to;

    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      delete approvedToTransfer[_tokenId];
    }

    Transfer(_from, _to, _tokenId);
  }

  /*** STRING UTILS ***/
  function strConcat(string _a, uint _b) internal pure returns (string) {
    bytes memory _ba = bytes(_a);
    string memory _bs = uintToString(_b);
    bytes memory _bb = bytes(_bs);
    string memory ab = new string(_ba.length + _bb.length);
    bytes memory bab = bytes(ab);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
    return string(bab);
  }

  function uintToString(uint _v) internal pure returns (string str) {
    uint v = _v;
    bytes32 packed = uintToPackedBytes(v);
    str = packedBytesToString(packed);
  }

  function uintToPackedBytes(uint v) internal pure returns (bytes32 ret) {
    if (v == 0) {
      return bytes32("0");
    }
    while (v > 0) {
      ret = bytes32(uint(ret) / 256);
      ret = ret | bytes32((v % 10 + 48) * 2 ** 248);
      v = v / 10;
    }
    return ret;
  }

  function packedBytesToString(bytes32 _x) internal pure returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
      byte char = byte(bytes32(uint(_x) * 2 ** (8 * j)));
      if (char != 0) {
        bytesString[charCount] = char;
        charCount++;
      }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
      bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
  }
}


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
