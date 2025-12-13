//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {AggregatorV3Interface} from "@chainlink/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMeTest is Test {
    // HelperConfig helperConfig = new HelperConfig();
    // FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());
    // FundMe fundMe;
    FundMe public fundMe;

    address payable user;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    mapping(address => uint256) public s_addressToAmountFunded;
    AggregatorV3Interface private s_pricefeed;
    address mockPriceFeed;


    function setUp() public {

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory activeNetworkConfig = helperConfig.getActiveNetworkConfig();

        emit log_address(activeNetworkConfig.priceFeed); 
        fundMe = new FundMe(activeNetworkConfig.priceFeed);
        // Give some ETH to user
        vm.deal(user, 10 ether);
        
    }

    function test_IfFundFunctionUsesRequire() public {
        //Arrange
        address payable user = payable(makeAddr("user"));
        vm.deal(user, 10 ether);

        //Act
        vm.prank(user);
        fundMe.fund{value: 5 ether}();

        //Assert
        uint256 amount = fundMe.s_addressToAmountFunded(user);
        console.log();
        assertEq(amount, 5 ether, "You have sent enough eth");
        console.log("Test Passed: fund function works correctly");
    }

    function test__IfgetVersionreturnsPriceFeed() public {
        //Arrange
        address user = makeAddr("user");

        //Act
        vm.prank(user);
        uint256 actualVersion = fundMe.getVersion();
        
        //failed test
        // uint256 actualVersion = s_pricefeed.version();
        uint256 currentVersion = fundMe.s_pricefeed().version();

        //Assert
        assertEq(actualVersion, currentVersion, "getVersion function returns currect version");
    }
}
