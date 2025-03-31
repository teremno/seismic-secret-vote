// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecretVote {
    address public owner;
    bool public votingOpen = true;

    mapping(address => bytes32) public encryptedVotes;
    mapping(address => bool) public hasVoted;
    mapping(address => bool) public hasRevealed;
    mapping(address => string) public revealedVotes;
    mapping(string => uint256) public voteCounts;

    event VoteSubmitted(address indexed voter);
    event VotingClosed();
    event VoteRevealed(address indexed voter, string vote);

    constructor() {
        owner = msg.sender;
    }

    function submitEncryptedVote(bytes32 encryptedVote) public {
        require(votingOpen, "Voting is closed");
        require(!hasVoted[msg.sender], "You have already voted");

        encryptedVotes[msg.sender] = encryptedVote;
        hasVoted[msg.sender] = true;

        emit VoteSubmitted(msg.sender);
    }

    function closeVoting() public {
        require(msg.sender == owner, "Only owner can close voting");
        votingOpen = false;

        emit VotingClosed();
    }

    function revealVote(string memory plainVote) public {
        require(!votingOpen, "Voting must be closed to reveal");
        require(hasVoted[msg.sender], "You did not vote");
        require(!hasRevealed[msg.sender], "Already revealed");

        bytes32 expected = encryptedVotes[msg.sender];
        require(keccak256(abi.encodePacked(plainVote)) == expected, "Vote does not match encrypted");

        hasRevealed[msg.sender] = true;
        revealedVotes[msg.sender] = plainVote;
        voteCounts[plainVote]++;

        emit VoteRevealed(msg.sender, plainVote);
    }
}

