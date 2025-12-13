//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        address priceFeed;

        vm.startBroadcast();
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getActiveNetworkConfig();
        console.log("PriceFeed:", config.priceFeed);

        FundMe fundMe = new FundMe(config.priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
