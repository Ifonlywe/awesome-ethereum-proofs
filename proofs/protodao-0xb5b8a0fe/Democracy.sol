// Submitted by EthereumHistory (ethereumhistory.com)
contract Democracy {

    uint public debatingPeriod;
    uint public voterShare;
    address public founder;
    Proposal[] public proposals;
    uint public numProposals;
    uint minimumQuorum;

    event ProposalAdded(uint proposalID, address recipient, uint amount, bytes32 data, string description);
    event Voted(uint proposalID, int position, address voter);
    event ProposalTallied(uint proposalID, int result, uint quorum, bool active);

    struct Proposal {
        address recipient;
        uint amount;
        bytes32 data;
        string description;
        uint creationDate;
        bool active;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
        int position;
        address voter;
    }

    function Democracy(uint _voterShare, uint _minimumQuorum, uint _debatingPeriod) {
        founder = msg.sender;
        voterShare = _voterShare;
        minimumQuorum = _minimumQuorum;
        debatingPeriod = _debatingPeriod * 1 minutes;
    }

    function newProposal(address _recipient, uint _amount, bytes32 _data, string _description) returns (uint proposalID) {
        proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = _recipient;
        p.amount = _amount;
        p.data = _data;
        p.description = _description;
        p.creationDate = now;
        p.active = true;
        ProposalAdded(proposalID, _recipient, _amount, _data, _description);
        numProposals = proposalID+1;
    }

    function vote(uint _proposalID, int _position) returns (uint voteID){
        if (_position >= -1 || _position <= 1 ) {
            Proposal p = proposals[_proposalID];
            if (p.voted[msg.sender] == true) return;
            voteID = p.votes.length++;
            p.votes[voteID] = Vote({position: _position, voter: msg.sender});
            p.voted[msg.sender] = true;
            Voted(_proposalID,  _position, msg.sender);
        }
    }

    function executeProposal(uint _proposalID) returns (int result) {
        Proposal p = proposals[_proposalID];
        /* Check if debating period is over */
        if (now > (p.creationDate + debatingPeriod) && p.active){
            uint quorum = 0;
            /* tally the votes */
            for (uint i = 0; i <  p.votes.length; ++i) {
                Vote v = p.votes[i];
                uint voteWeight = voterShare;
                quorum += voteWeight;
                result += int(voteWeight) * v.position;
            }
            p.active = false;
            ProposalTallied(_proposalID, result, quorum, p.active);
        }
    }

    function kill() { if (msg.sender == founder) suicide(founder); }
}
