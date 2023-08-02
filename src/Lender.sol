// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ILender} from "./interfaces/ILender.sol";

contract Lender is ILender {
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    mapping(address => uint256) borrowers;

    function borrow(uint256 amount) external {
        //reduct usdt this contract holding

        //transfer money to the user
    }
    function repay() external {
        //get current amount
        //adding 10%
    }
}
