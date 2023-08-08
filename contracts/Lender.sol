// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {ILender} from "./interfaces/ILender.sol";

contract Lender is ILender {
    using Math for uint256;
    using SafeERC20 for IERC20;

    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    // mapping of the borrower address to debt amount
    mapping(address => uint256) public borrowerDebts;

    // @dev the caller borrows USDT amount from the contract
    // @param the amount needed to borrow
    function borrow(uint256 amount) external {
        // can't borrow 0 amount
        if (amount == 0) {
            revert ZeroAmount();
        }
        // transfer token to the user
        IERC20(USDT).safeTransfer(msg.sender, amount);
        // add debt record along with 10% interest
        uint256 _debtWithInterest = amount.mulDiv(110, 100);
        borrowerDebts[msg.sender] += _debtWithInterest;
    }

    // @dev the caller repays the borrowed amount + 10% interest fixed for any period of time
    function repay() external {
        // reuse variable
        address _usdt = USDT;
        // get current contract's balance
        uint256 _preBalance = IERC20(_usdt).balanceOf(address(this));
        // get borrower debt
        uint256 _borrowerDebt = borrowerDebts[msg.sender];
        // get user balance
        uint256 _borrowerBalance = IERC20(_usdt).balanceOf(msg.sender);
        // user doesn't has enough balance to repay
        if (_borrowerBalance < _borrowerDebt) {
            revert NotEnoughBalance();
        }
        // receive repay for debt with intereest
        IERC20(_usdt).safeTransferFrom(msg.sender, address(this), _borrowerDebt);
        // calculate repayedAmount = postBalance - preBalance
        uint256 repayedAmount = IERC20(_usdt).balanceOf(address(this)) - _preBalance;
        // deduct the borrower debt
        borrowerDebts[msg.sender] = _borrowerDebt - repayedAmount;
    }
}
