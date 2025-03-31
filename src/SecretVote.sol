// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecretVote {
    address public owner;
    bool public votingOpen = true;
    uint256 public votingDeadline;

    mapping(address => bytes32) public encryptedVotes;
    mapping(address => bool) public hasVoted;
    mapping(address => bool) public hasRevealed;
    mapping(address => string) public revealedVotes;
    mapping(string => uint256) public voteCounts;

    address[] public revealedVoters; // 👈 NEW

    event VoteSubmitted(address indexed voter);
    event VotingClosed();
    event VoteRevealed(address indexed voter, string vote);
    event VotingDeadlineSet(uint256 deadline);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    modifier onlyBeforeDeadline() {
        require(
            votingDeadline == 0 || block.timestamp <= votingDeadline,
            "Voting deadline passed"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setVotingDeadline(uint256 timestamp) public onlyOwner {
        votingDeadline = timestamp;
        emit VotingDeadlineSet(timestamp);
    }

    function submitEncryptedVote(bytes32 encryptedVote)
        public
        onlyBeforeDeadline
    {
        require(votingOpen, "Voting is closed");
        require(!hasVoted[msg.sender], "You have already voted");

        encryptedVotes[msg.sender] = encryptedVote;
        hasVoted[msg.sender] = true;

        emit VoteSubmitted(msg.sender);
    }

    function closeVoting() public onlyOwner {
        votingOpen = false;
        emit VotingClosed();
    }

    function revealVote(string memory plainVote) public {
        require(!votingOpen, "Voting must be closed to reveal");
        require(hasVoted[msg.sender], "You did not vote");
        require(!hasRevealed[msg.sender], "Already revealed");

        bytes32 expected = encryptedVotes[msg.sender];
        require(
            keccak256(abi.encodePacked(plainVote)) == expected,
            "Vote does not match encrypted"
        );

        hasRevealed[msg.sender] = true;
        revealedVotes[msg.sender] = plainVote;
        voteCounts[plainVote]++;
        revealedVoters.push(msg.sender); // 👈 NEW

        emit VoteRevealed(msg.sender, plainVote);
    }

    // 👇 NEW function
    function getAllRevealedVotes()
        public
        view
        returns (address[] memory, string[] memory)
    {
        uint256 count = revealedVoters.length;
        string[] memory votes = new string[](count);

        for (uint256 i = 0; i < count; i++) {
            votes[i] = revealedVotes[revealedVoters[i]];
        }

        return (revealedVoters, votes);
    }
}

