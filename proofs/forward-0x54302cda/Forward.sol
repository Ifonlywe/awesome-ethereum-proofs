contract Forward {
    function forward(address account) returns (bool) {
        return account.send(msg.value);
    }
}
