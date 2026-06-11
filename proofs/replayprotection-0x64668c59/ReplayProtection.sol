contract Token {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

// replay protection
contract ReplayProtection {
    bytes32 public chainSignature;

    function ReplayProtection() {
        for (uint i = 1; i < 16; i++) {
            chainSignature = sha3(chainSignature, block.blockhash(block.number - i));
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
