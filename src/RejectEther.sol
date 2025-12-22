// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";

contract RejectEther {
    FundMe public fundMe;

    constructor(address priceFeed) {
        fundMe = new FundMe(priceFeed);
    }

    function callWithdraw() external {
        fundMe.withdraw();
    }

    receive() external payable {
        revert("Rejecting ETH");
    }

    fallback() external payable {
        revert("Rejecting ETH");
    }
}
