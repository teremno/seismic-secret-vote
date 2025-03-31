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

        vm.prank(voter); // голосує від імені voter
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
}

