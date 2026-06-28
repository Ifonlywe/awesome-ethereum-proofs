// Verified by EthereumHistory (ethereumhistory.com)
// Source: go-ethereum common/registrar/contracts.go (UrlHintSrc), the Ethereum
// Foundation's hardcoded Frontier registrar. The on-chain runtime at
// 0x73ed5ef6c010727dfd2671dbb70faac19ec18626 is byte-for-byte identical to the
// `UrlHintCode` constant compiled into go-ethereum.

contract URLhint {
	function register(uint256 _hash, uint8 idx, uint256 _url) {
		if (owner[_hash] == 0 || owner[_hash] == msg.sender) {
			owner[_hash] = msg.sender;
			url[_hash][idx] = _url;
		}
	}
	mapping (uint256 => address) owner;
	mapping (uint256 => uint256[256]) url;
}
