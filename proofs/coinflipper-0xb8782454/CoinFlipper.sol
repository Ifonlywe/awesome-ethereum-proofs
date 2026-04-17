// Compiler: solc 0.1.0 --optimize (exact match with solc 0.0.9.27 through 0.1.1, optimized)
// Contract: 0xb87824547db80f1fb37d0225b99f1a602f8642ad
// Deployed: 2015-08-08 (block 55627)
// Match: 100% exact bytecode match (186/186 bytes)
contract CoinFlipper {
    uint256 public flip;
    function donate() {
    }
    function() {
        var v = msg.value;
        var b = address(this).balance;
        if (v > 2 * b) {
            return;
        }
        flip = block.timestamp;
        if (flip % 2 == 0) {
        } else {
            msg.sender.send(2 * v);
        }
    }
}
