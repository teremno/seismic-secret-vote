// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecretVote {
    address public owner;
    bool public votingOpen = true;

    mapping(address => bytes32) public encryptedVotes;
    mapping(address => bool) public hasVoted;

    event VoteSubmitted(address indexed voter);
    event VotingClosed();

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

    // Optional: revealVotes, result, etc.
}

