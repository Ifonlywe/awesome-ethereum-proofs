contract Token {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

// replay protection
contract ReplayProtection {
    bytes32 public chainSignature;

    function ReplayProtection() {
        bytes32 blockHash = 0xcf9055c648b3689a2b74e980fc6fa27817622fa9ac0749d60a6489a7fbcfe831;
        for (uint i = 1; i < 64; i++) {
            if (blockHash == block.blockhash(block.number - i)) chainSignature = blockHash;
        }
    }

    function etherSplit(address recipient, address altChainRecipient, bytes32 _chainSignature) returns(bool) {
        if (chainSignature == _chainSignature && recipient.send(msg.value)) {
            return true;
        } else if (chainSignature != _chainSignature && altChainRecipient.send(msg.value)) {
            return true;
        }
        throw;
    }

    function tokenSplit(address recipient, address altChainRecipient, address tokenAddress, uint amount, bytes32 _chainSignature) returns (bool) {
        if (msg.value > 0 ) throw;
        Token token = Token(tokenAddress);
        if (chainSignature == _chainSignature && token.transferFrom(msg.sender, recipient, amount)) {
            return true;
        } else if (chainSignature != _chainSignature && token.transferFrom(msg.sender, altChainRecipient, amount)) {
            return true;
        }
        throw;
    }

    function () {
        throw;
    }
}
