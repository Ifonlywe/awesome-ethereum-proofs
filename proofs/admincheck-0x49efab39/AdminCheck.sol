contract T {
    address owner;

    function kill() { suicide(owner); }

    function get() returns (address) { return owner; }

    function test() returns (bool) {
        return msg.sender == 0x8b9346aa412b52954b5138dbb72adab97273766e;
    }
}
