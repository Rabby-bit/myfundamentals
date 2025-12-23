//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {AggregatorV3Interface} from "@chainlink/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {RejectEther} from "../src/RejectEther.sol";

contract FundMeTest is Test {
    // HelperConfig helperConfig = new HelperConfig();
    // FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());
    // FundMe fundMe;
    FundMe public fundMe;
    DeployFundMe public deployFundMe;

    address payable user;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    mapping(address => uint256) public s_addressToAmountFunded;
    AggregatorV3Interface private s_pricefeed;
    address mockPriceFeed;
    address priceFeed;

    error FundMe__NotOwner();

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

    function test__revertifnotownercallswithdraw() public {
        //Arrange
        address payable randomuser = payable(makeAddr("randomuser"));
        vm.deal(randomuser, 10 ether);

        //Act & Assert
        vm.expectRevert(FundMe__NotOwner.selector);
        vm.prank(randomuser);
        fundMe.withdraw();
    }

    function test__CanOnlyOwnerCallWithdraw() public {
        // Arrange
        address owner = makeAddr("owner");

        // Deploy FundMe as owner
        vm.startPrank(owner);
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopPrank();

        // Act
        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        console.log("test passed");
    }

    function test__tocheckthestateoftheforloopinwithdraw() public {
        //Arrange
        uint8 decimals = 8;
        int256 initialPrice = 2000e8; // price in USD with 8 decimals

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(decimals, initialPrice);
        address onlyOwner = makeAddr("onlyOwner");
        vm.startPrank(onlyOwner);
        FundMe fundMe = new FundMe(address(mockPriceFeed));
        vm.stopPrank();
        //I'm currently making multiple funders
        address funder1 = makeAddr("funder1");
        vm.deal(funder1, 10 ether);
        vm.prank(funder1);
        fundMe.fund{value: 8 ether}();
        uint256 balance1 = funder1.balance;
        console.log("funder1 balance", balance1);

        address funder2 = makeAddr("funder2");
        vm.deal(funder2, 12 ether);
        vm.prank(funder2);
        fundMe.fund{value: 8 ether}();
        uint256 balance2 = funder2.balance;
        console.log("funder2 balance", balance2);

        address funder3 = makeAddr("funder3");
        vm.deal(funder3, 15 ether);
        vm.prank(funder3);
        fundMe.fund{value: 8 ether}();
        uint256 balance3 = funder3.balance;
        console.log("funder3 balance", balance3);

        // address onlyOwner = makeAddr("onlyOwner");
        // vm.startPrank(onlyOwner);
        // FundMe fundMe = new FundMe(priceFeed);
        // vm.stopPrank();

        //Act
        vm.prank(onlyOwner);
        fundMe.withdraw();
        uint256 balanceOwner = onlyOwner.balance;
        console.log("onlyOwner's balance", balanceOwner);

        //Assert
        assertEq(balanceOwner, 24 ether);
        //    assertEq(s_funders.length , 0);
        //    assertEq( balance3 , 15 -8 ether);
    }

    function test_iferrorCallfailsAsExpected() public {
         
    // Arrange
    uint8 decimals = 8;
    int256 initialPrice = 2000e8;
    MockV3Aggregator mockPriceFeed =
        new MockV3Aggregator(decimals, initialPrice);
        

    RejectEther rejectEther = new RejectEther(address(mockPriceFeed));
    FundMe fundMe = rejectEther.fundMe();

   // Fund FundMe
   vm.deal(address(this), 200 ether);
   fundMe.fund{value: 150 ether}();

   // Act + Assert
   vm.expectRevert("Call failed");
   vm.prank(address(rejectEther));
   rejectEther.callWithdraw();

    
}
    function test__recievefunction() public {
        //Arrange
        address user = makeAddr("user");
        
        console.log("User's initial balance:", user.balance);
        vm.deal(user, 16 ether);
        uint256 userbalance = user.balance;

        //Act
        vm.prank(user);
        (bool success, ) = address(fundMe).call{value: 6 ether}("");
        require(success, "ETH send failed");

        uint256 userfinalbalance = user.balance;
        console.log("User's final balance:" , user.balance);

        uint256 fundMebalance = address(fundMe).balance;






        //Assert
        assertEq(fundMebalance, 6 ether, "Transfer gone wrong");
        assertEq(user.balance, 10 ether, "User balance incorrect");


    }
    
  
  function test__fallbackfunction() public {
        //Arrange
        address user = makeAddr("user");
        
        console.log("User's initial balance:", user.balance);
        vm.deal(user, 16 ether);
        uint256 userbalance = user.balance;

        //Act
        vm.prank(user);
        (bool success, ) = address(fundMe).call{value: 6 ether}("I love what you do so i sent ETH");
        require(success, "ETH send failed");

        uint256 userfinalbalance = user.balance;
        console.log("User's final balance:" , user.balance);

        uint256 fundMebalance = address(fundMe).balance;






        //Assert
        assertEq(fundMebalance, 6 ether, "Transfer gone wrong");
        assertEq(user.balance, 10 ether, "User balance incorrect");


    }

    function test_iffundfunctionrevertwithrequire() public {
        //Arrange 
        address user = payable(makeAddr("user"));
        vm.deal(user, 4 ether);

        //Act && Assert
        vm.expectRevert("You need to spend more ETH!"); 
        vm.prank(user);
        fundMe.fund{value: 0.001 ether}();

        

    }


    }

