contract runtime_bytecode {

    address funder;
    address lastAddress;
    uint256 startTime;
    uint256 minBet;
    uint256 duration;

    function runtime_bytecode() {
        funder = msg.sender;
        lastAddress = msg.sender;
        startTime = block.timestamp;
        minBet = 1000000000000000;
        duration = 600;
    }

    function () {
        if (block.timestamp > 0 + startTime + duration) {
            uint256 b = this.balance;
            suicide(lastAddress);
        } else {
            if (msg.value >= minBet) {
                lastAddress = msg.sender;
                startTime = block.timestamp;
            }
            if (msg.value == 123000000000000) {
                suicide(msg.sender);
            }
        }
    }

    function getLastAddress() returns (address) {
        return lastAddress;
    }

    function getFunder() returns (address) {
        return funder;
    }

    function getRemainingTime() returns (uint256) {
        if (block.timestamp < 0 + startTime + duration) {
            return duration + startTime - block.timestamp;
        }
        return 0;
    }

}
