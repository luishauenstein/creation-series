// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";
import "../src/CreationSeries.sol";

contract CreationSeriesScript is Script {
    function run() public {
        string memory name = "The Creation Series";
        string memory symbol = "CREATION";
        string memory baseURI = "https://creation-series-metadata.luish.xyz/";
        string memory tokenURISuffix = ".json";

        vm.startBroadcast();
        new CreationSeries(name, symbol, baseURI, tokenURISuffix);  
        vm.stopBroadcast();
    }
}
