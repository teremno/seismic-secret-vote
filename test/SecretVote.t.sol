// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/SecretVote.sol";

contract SecretVoteTest is Test {
    SecretVote public voteContract;
    address voter = address(0xBEEF);

    function setUp() public {
        voteContract = new SecretVote();
    }

    function testSubmitEncryptedVote() public {
        bytes32 encrypted = keccak256(abi.encodePacked("yes"));

        vm.prank(voter);
        voteContract.submitEncryptedVote(encrypted);

        bytes32 stored = voteContract.encryptedVotes(voter);
        assertEq(stored, encrypted, "Stored vote should match encrypted input");
    }

    function testDoubleVoteShouldFail() public {
        bytes32 encrypted = keccak256(abi.encodePacked("yes"));

        vm.prank(voter);
        voteContract.submitEncryptedVote(encrypted);

        vm.prank(voter);
        vm.expectRevert("You have already voted");
        voteContract.submitEncryptedVote(encrypted);
    }

    function testRevealVoteSuccess() public {
        bytes32 encrypted = keccak256(abi.encodePacked("yes"));

        vm.prank(voter);
        voteContract.submitEncryptedVote(encrypted);

        voteContract.closeVoting();

        vm.prank(voter);
        voteContract.revealVote("yes");

        string memory revealed = voteContract.revealedVotes(voter);
        assertEq(revealed, "yes", "Vote should be revealed correctly");

        uint256 count = voteContract.voteCounts("yes");
        assertEq(count, 1, "Vote count should increase");
    }

    function testRevealWithWrongStringShouldFail() public {
        bytes32 encrypted = keccak256(abi.encodePacked("yes"));

        vm.prank(voter);
        voteContract.submitEncryptedVote(encrypted);

        voteContract.closeVoting();

        vm.prank(voter);
        vm.expectRevert("Vote does not match encrypted");
        voteContract.revealVote("no");
    }

    function testDoubleRevealShouldFail() public {
        bytes32 encrypted = keccak256(abi.encodePacked("yes"));

        vm.prank(voter);
        voteContract.submitEncryptedVote(encrypted);

        voteContract.closeVoting();

        vm.prank(voter);
        voteContract.revealVote("yes");

        vm.prank(voter);
        vm.expectRevert("Already revealed");
        voteContract.revealVote("yes");
    }

    function testSetVotingDeadline() public {
        uint256 deadline = block.timestamp + 1 days;
        voteContract.setVotingDeadline(deadline);

        assertEq(voteContract.votingDeadline(), deadline, "Deadline should be set");
    }

    function testVotingBeforeDeadlineWorks() public {
        uint256 deadline = block.timestamp + 1 days;
        voteContract.setVotingDeadline(deadline);

        bytes32 encrypted = keccak256(abi.encodePacked("yes"));
        vm.prank(voter);
        voteContract.submitEncryptedVote(encrypted);

        assertTrue(voteContract.hasVoted(voter), "Vote should be recorded");
    }

    function testVotingAfterDeadlineFails() public {
        uint256 deadline = block.timestamp + 1 days;
        voteContract.setVotingDeadline(deadline);

        vm.warp(block.timestamp + 2 days); // прокручуємо час

        bytes32 encrypted = keccak256(abi.encodePacked("yes"));
        vm.prank(voter);
        vm.expectRevert("Voting deadline passed");
        voteContract.submitEncryptedVote(encrypted);
    }
}

