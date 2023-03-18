// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import "../src/CreativeJourney.sol";

contract CreativeJourneyTest is Test {
    CreativeJourney public creativeJourney;

    function setUp() public {
        creativeJourney = new CreativeJourney("CreativeJourneyTest", "CJT", "https://nft.luish.xyz/", ".json");
        creativeJourney.setSalePrice(0.1 ether);
        creativeJourney.increaseMaxSupply(1);
    }

    // set sale price as owner
    function testSetSalePrice() public {
        assertEq(creativeJourney.salePrice(), 0.1 ether);
    }

    // fail setting sale price as non-owner
    function testFailSetSalePrice() public {
        vm.prank(address(1));
        creativeJourney.setSalePrice(0 ether);
    }

    // increase max supply as owner
    function testIncreaseMaxSupply() public {
        assertEq(creativeJourney.MAX_SUPPLY(), 1);
    }

    // fail increasing max supply as non-owner
    function testFailIncreaseMaxSupply() public {
        vm.prank(address(1));
        creativeJourney.increaseMaxSupply(1);
    }

    // mint() when totalSupply < MAX_SUPPLY
    function testMintWithinRange() public {
        address myAddress = msg.sender;
        creativeJourney.mint(myAddress);
        assertEq(creativeJourney.totalSupply(), 1);
        assertEq(creativeJourney.MAX_SUPPLY(), 1);
        assertEq(creativeJourney.ownerOf(1), msg.sender);
    }

    // mint() when totalSupply = MAX_SUPPLY
    function testMintOutsideRange() public {
        address myAddress = msg.sender;
        creativeJourney.mint(myAddress); // first mint within range
        creativeJourney.mint(myAddress); // second mint outside range
        assertEq(creativeJourney.totalSupply(), 2);
        assertEq(creativeJourney.MAX_SUPPLY(), 2);
        assertEq(creativeJourney.ownerOf(1), msg.sender);
        assertEq(creativeJourney.ownerOf(2), msg.sender);
    }

    // mint() fails due to owner check
    function testFailMint() public {
        vm.prank(address(1));
        creativeJourney.mint(address(1));
    }

    // random user successfully mints via public mint function
    function testMintPublic() public {
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        creativeJourney.mintPublic{value: 0.1 ether}();
        assertEq(creativeJourney.ownerOf(1), alice);
        assertEq(address(creativeJourney).balance, 0.1 ether);
    }

    // random user fails to mint due to low msg value
    function testFailMintPublicValue() public {
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        creativeJourney.mintPublic{value: 0.05 ether}();
    }

    // public mint fails due to max supply reached
    function testFailMintPublicSupply() public {
        creativeJourney.mint(address(2)); // to reach max supply
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        creativeJourney.mintPublic{value: 0.1 ether}();
        assertEq(creativeJourney.totalSupply(), 1);
        assertEq(creativeJourney.MAX_SUPPLY(), 1);
    }
    
    // withdraw() should work as owner
    function testWithdraw() public {
        // give ether to contract
        vm.deal(address(creativeJourney), 1 ether);
        assertEq(address(creativeJourney).balance, 1 ether);
        // transfer ownership to EOA (since forge test deployer is a non-payable contract)
        address ownerEOA = address(21);
        creativeJourney.transferOwnership(ownerEOA);
        // execute withdrawal
        vm.prank(ownerEOA);
        creativeJourney.withdraw();
        assertEq(ownerEOA.balance, 1 ether);
    }

    // withdraw() should fail as non-owner
    function testFailWithdraw() public {
        // give ether to contract
        vm.deal(address(creativeJourney), 1 ether);
        assertEq(address(creativeJourney).balance, 1 ether);
        // transfer ownership to EOA (since forge test deployer is a non-payable contract)
        address ownerEOA = address(21);
        creativeJourney.transferOwnership(ownerEOA);
        // execute withdrawal
        vm.prank(address(22));
        creativeJourney.withdraw();
        assertEq(ownerEOA.balance, 0 ether);
        assertEq(address(creativeJourney).balance, 1 ether);
    }


    // token URI tests still missing
}
