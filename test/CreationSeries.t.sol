// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import "../src/CreationSeries.sol";

contract CreationSeriesTest is Test {
    CreationSeries public CreationSeries;

    function setUp() public {
        CreationSeries = new CreationSeries("The Creation Series", "CREATION", "https://creation-series-metadata.luish.xyz/", ".json");
        CreationSeries.setSalePrice(0.1 ether);
        CreationSeries.increaseMaxSupply(1);
    }

    // set sale price as owner
    function testSetSalePrice() public {
        assertEq(CreationSeries.salePrice(), 0.1 ether);
    }

    // fail setting sale price as non-owner
    function testFailSetSalePrice() public {
        vm.prank(address(1));
        CreationSeries.setSalePrice(0 ether);
    }

    // increase max supply as owner
    function testIncreaseMaxSupply() public {
        assertEq(CreationSeries.MAX_SUPPLY(), 1);
    }

    // fail increasing max supply as non-owner
    function testFailIncreaseMaxSupply() public {
        vm.prank(address(1));
        CreationSeries.increaseMaxSupply(1);
    }

    // mint() when totalSupply < MAX_SUPPLY
    function testMintWithinRange() public {
        address myAddress = msg.sender;
        CreationSeries.mint(myAddress);
        assertEq(CreationSeries.totalSupply(), 1);
        assertEq(CreationSeries.MAX_SUPPLY(), 1);
        assertEq(CreationSeries.ownerOf(1), msg.sender);
    }

    // mint() when totalSupply = MAX_SUPPLY
    function testMintOutsideRange() public {
        address myAddress = msg.sender;
        CreationSeries.mint(myAddress); // first mint within range
        assertEq(CreationSeries.MAX_SUPPLY(), 1);
        CreationSeries.mint(myAddress); // second mint outside range
        assertEq(CreationSeries.totalSupply(), 2);
        assertEq(CreationSeries.MAX_SUPPLY(), 2);
        assertEq(CreationSeries.ownerOf(1), msg.sender);
        assertEq(CreationSeries.ownerOf(2), msg.sender);
    }

    // mint() fails due to owner check
    function testFailMint() public {
        vm.prank(address(1));
        CreationSeries.mint(address(1));
    }

    // random user successfully mints via public mint function
    function testMintPublic() public {
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        CreationSeries.mintPublic{value: 0.1 ether}();
        assertEq(CreationSeries.ownerOf(1), alice);
        assertEq(address(CreationSeries).balance, 0.1 ether);
    }

    // random user fails to mint due to low msg value
    function testFailMintPublicValue() public {
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        CreationSeries.mintPublic{value: 0.05 ether}();
    }

    // public mint fails due to max supply reached
    function testFailMintPublicSupply() public {
        CreationSeries.mint(address(2)); // to reach max supply
        address alice = address(1);
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        CreationSeries.mintPublic{value: 0.1 ether}();
        assertEq(CreationSeries.totalSupply(), 1);
        assertEq(CreationSeries.MAX_SUPPLY(), 1);
    }
    
    // withdraw() should work as owner
    function testWithdraw() public {
        // give ether to contract
        vm.deal(address(CreationSeries), 1 ether);
        assertEq(address(CreationSeries).balance, 1 ether);
        // transfer ownership to EOA (since forge test deployer is a non-payable contract)
        address ownerEOA = address(21);
        CreationSeries.transferOwnership(ownerEOA);
        // execute withdrawal
        vm.prank(ownerEOA);
        CreationSeries.withdraw();
        assertEq(ownerEOA.balance, 1 ether);
    }

    // withdraw() should fail as non-owner
    function testFailWithdraw() public {
        // give ether to contract
        vm.deal(address(CreationSeries), 1 ether);
        assertEq(address(CreationSeries).balance, 1 ether);
        // transfer ownership to EOA (since forge test deployer is a non-payable contract)
        address ownerEOA = address(21);
        CreationSeries.transferOwnership(ownerEOA);
        // execute withdrawal
        vm.prank(address(22));
        CreationSeries.withdraw();
        assertEq(ownerEOA.balance, 0 ether);
        assertEq(address(CreationSeries).balance, 1 ether);
    }


    // token URI tests still missing
    function testTokenURI() public {
        CreationSeries.mint(msg.sender);
        CreationSeries.mint(msg.sender);
        // return correct token URI
        assertEq(CreationSeries.tokenURI(1), "https://nft.luish.xyz/1.json");
        assertEq(CreationSeries.tokenURI(2), "https://nft.luish.xyz/2.json");
        // test updating baseURI
        CreationSeries.setBaseURI("https://abc.xyz/");
        assertEq(CreationSeries.tokenURI(1), "https://abc.xyz/1.json");
        // test updating URISuffix
        CreationSeries.setTokenURISuffix(".html");
        assertEq(CreationSeries.tokenURI(1), "https://abc.xyz/1.html");
        CreationSeries.setTokenURISuffix("");
        assertEq(CreationSeries.tokenURI(1), "https://abc.xyz/1");
    }

    // updating baseURI fails as non-owner
    function testFailUpdateBaseURI() public {
        vm.prank(address(21));
        CreationSeries.setBaseURI("https://abc.xyz/");
    }

    // updating tokenURISuffix fails as non-owner
    function testFailUpdatetokenURISuffix() public {
        vm.prank(address(21));
        CreationSeries.setTokenURISuffix("");
    }
}
