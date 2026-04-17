contract Target {
    uint stored;

    function set(uint256 x) {
        stored = x;
    }

    function get() returns (uint) {
        return stored;
    }
}
