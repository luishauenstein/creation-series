// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";
import "../src/CreativeJourney.sol";

contract CreativeJourneyTest is Test {
    CreativeJourney public creativeJourney;

    function setUp() public {
        creativeJourney = new CreativeJourney("CreativeJourneyTest", "CJT", "https://nft.luish.xyz/", ".json");
        creativeJourney.increaseMaxSupply(1);
    }

    function testIncreaseMaxSupply() public {
        assertEq(creativeJourney.MAX_SUPPLY(), 1);
    }
}
