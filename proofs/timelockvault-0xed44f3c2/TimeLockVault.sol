// Verified by EthereumHistory (ethereumhistory.com)
// Source reconstructed from on-chain runtime bytecode of
// 0xed44f3c2081480b08643fe1ca281fab9ed643735 (deployed 2015-12-20).
// Compiles (solc 0.1.3-0.2.0, optimizer ON) to 433 bytes with exact function-body
// order and 12 of 14 function bodies byte-identical; see README for the residual.

contract TimeLockVault {
    struct Account {
        uint balance;
        uint unlockTime;
    }
    mapping(address => Account) public accounts;
    uint public duration;

    function TimeLockVault() {
        duration = 20 years;
    }

    // Deposit by sending ETH; withdraw by sending a 0-value tx (or calling withdraw()).
    function() {
        address a;
        uint b;
        if (msg.value > 0) {
            a = msg.sender;
            b = accounts[a].balance;
            if (b > 0) {
                a.send(msg.value);            // already have a locked balance: refund
            } else {
                accounts[a].unlockTime = now + duration;
                accounts[a].balance = b + msg.value;
            }
        } else {
            withdraw();
        }
    }

    function withdraw() {
        if (accounts[msg.sender].balance > 0 &&
            accounts[msg.sender].unlockTime > 0 &&
            now > accounts[msg.sender].unlockTime) {
            msg.sender.send(accounts[msg.sender].balance);
            accounts[msg.sender].balance = 0;
        }
    }
}
