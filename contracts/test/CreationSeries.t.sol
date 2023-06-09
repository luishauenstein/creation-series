// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import "../src/CreationSeries.sol";

contract CreationSeriesTest is Test {
    CreationSeries public creationSeries;

    function setUp() public {
        creationSeries = new CreationSeries("The Creation Series", "CREATION", "https://creation-series-metadata.luish.xyz/", ".json");
        creationSeries.setSalePrice(0.1 ether);
        creationSeries.increaseMaxSupply(1);
    }

    // set sale price as owner
    function testSetSalePrice() public {
        assertEq(creationSeries.salePrice(), 0.1 ether);
    }

    // fail setting sale price as non-owner
    function testFailSetSalePrice() public {
        vm.prank(address(1));
        creationSeries.setSalePrice(0 ether);
    }

    // increase max supply as owner
    function testIncreaseMaxSupply() public {
        assertEq(creationSeries.MAX_SUPPLY(), 1);
    }

    // fail increasing max supply as non-owner
    function testFailIncreaseMaxSupply() public {
        vm.prank(address(1));
        creationSeries.increaseMaxSupply(1);
    }

    // mint() when totalSupply < MAX_SUPPLY
    function testMintWithinRange() public {
        address myAddress = msg.sender;
        creationSeries.mint(myAddress);
        assertEq(creationSeries.totalSupply(), 1);
        assertEq(creationSeries.MAX_SUPPLY(), 1);
        assertEq(creationSeries.ownerOf(1), msg.sender);
    }

    // mint() when totalSupply = MAX_SUPPLY
    function testMintOutsideRange() public {
        address myAddress = msg.sender;
        creationSeries.mint(myAddress); // first mint within range
        assertEq(creationSeries.MAX_SUPPLY(), 1);
        creationSeries.mint(myAddress); // second mint outside range
        assertEq(creationSeries.totalSupply(), 2);
        assertEq(creationSeries.MAX_SUPPLY(), 2);
        assertEq(creationSeries.ownerOf(1), msg.sender);
        assertEq(creationSeries.ownerOf(2), msg.sender);
    }

    // mint() fails due to owner check
    function testFailMint() public {
        vm.prank(address(1));
        creationSeries.mint(address(1));
    }

    // random user successfully mints via public mint function
    function testMintPublic() public {
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        creationSeries.mintPublic{value: 0.1 ether}();
        assertEq(creationSeries.ownerOf(1), alice);
        assertEq(address(creationSeries).balance, 0.1 ether);
    }

    // random user fails to mint due to low msg value
    function testFailMintPublicValue() public {
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        creationSeries.mintPublic{value: 0.05 ether}();
    }

    // public mint fails due to max supply reached
    function testFailMintPublicSupply() public {
        creationSeries.mint(address(2)); // to reach max supply
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        creationSeries.mintPublic{value: 0.1 ether}();
        assertEq(creationSeries.totalSupply(), 1);
        assertEq(creationSeries.MAX_SUPPLY(), 1);
    }
    
    // withdraw() should work as owner
    function testWithdraw() public {
        // give ether to contract
        vm.deal(address(creationSeries), 1 ether);
        assertEq(address(creationSeries).balance, 1 ether);
        // transfer ownership to EOA (since forge test deployer is a non-payable contract)
        address ownerEOA = address(21);
        creationSeries.transferOwnership(ownerEOA);
        // execute withdrawal
        vm.prank(ownerEOA);
        creationSeries.withdraw();
        assertEq(ownerEOA.balance, 1 ether);
    }

    // withdraw() should fail as non-owner
    function testFailWithdraw() public {
        // give ether to contract
        vm.deal(address(creationSeries), 1 ether);
        assertEq(address(creationSeries).balance, 1 ether);
        // transfer ownership to EOA (since forge test deployer is a non-payable contract)
        address ownerEOA = address(21);
        creationSeries.transferOwnership(ownerEOA);
        // execute withdrawal
        vm.prank(address(22));
        creationSeries.withdraw();
        assertEq(ownerEOA.balance, 0 ether);
        assertEq(address(creationSeries).balance, 1 ether);
    }


    // token URI tests still missing
    function testTokenURI() public {
        creationSeries.mint(msg.sender);
        creationSeries.mint(msg.sender);
        // return correct token URI
        assertEq(creationSeries.tokenURI(1), "https://creation-series-metadata.luish.xyz/1.json");
        assertEq(creationSeries.tokenURI(2), "https://creation-series-metadata.luish.xyz/2.json");
        // test updating baseURI
        creationSeries.setBaseURI("https://abc.xyz/");
        assertEq(creationSeries.tokenURI(1), "https://abc.xyz/1.json");
        // test updating URISuffix
        creationSeries.setTokenURISuffix(".html");
        assertEq(creationSeries.tokenURI(1), "https://abc.xyz/1.html");
        creationSeries.setTokenURISuffix("");
        assertEq(creationSeries.tokenURI(1), "https://abc.xyz/1");
    }

    // updating baseURI fails as non-owner
    function testFailUpdateBaseURI() public {
        vm.prank(address(21));
        creationSeries.setBaseURI("https://abc.xyz/");
    }

    // updating tokenURISuffix fails as non-owner
    function testFailUpdatetokenURISuffix() public {
        vm.prank(address(21));
        creationSeries.setTokenURISuffix("");
    }
}
