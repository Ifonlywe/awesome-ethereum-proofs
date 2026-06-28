// Submitted by EthereumHistory (ethereumhistory.com)
contract Marriage {
    address owner;
    bytes32 public partner1;
    bytes32 public partner2;
    uint256 public marriageDate;
    bytes32 public marriageStatus;
    bytes public imageHash;
    bytes public marriageProofDoc;

    function Marriage() {
        owner = msg.sender;
    }

    function createMarriage(bytes32 partner1Entry, bytes32 partner2Entry, uint256 marriageDateEntry, bytes32 statusEntry, bytes descriptionEntry) {
        partner1 = partner1Entry;
        partner2 = partner2Entry;
        marriageDate = marriageDateEntry;
        setStatus(statusEntry);
        bytes32 name = "Marriage Contract Creation";
        MajorEvent(block.timestamp, marriageDate, name, descriptionEntry);
    }

    function setStatus(bytes32 status) {
        marriageStatus = status;
    }

    function setImage(bytes IPFSImageHash) {
        imageHash = IPFSImageHash;
    }

    function marriageProof(bytes IPFSProofHash) {
        marriageProofDoc = IPFSProofHash;
    }

    function majorEvent(bytes32 name, bytes description, uint256 eventTimeStamp) {
        MajorEvent(block.timestamp, eventTimeStamp, name, description);
    }

    function returnFunds() {
        var b = this.balance;
        owner.send(b);
    }

    event MajorEvent(uint256 logTimeStamp, uint256 eventTimeStamp, bytes32 indexed name, bytes indexed description);
}
