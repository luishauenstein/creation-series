// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";
import "../src/CreativeJourney.sol";

contract CreativeJourneyScript is Script {
    function run() public {
        string memory name = "The Creation Series";
        string memory symbol = "CREATION";
        string memory baseURI = "https://nft.luish.xyz/";
        string memory tokenURISuffix = ".json";

        vm.startBroadcast();
        new CreativeJourney(name, symbol, baseURI, tokenURISuffix);  
        vm.stopBroadcast();
    }
}
