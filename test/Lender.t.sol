// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {Lender} from "../contracts/Lender.sol";

contract LenderTest is Test {
    using Math for uint256;
    using SafeERC20 for IERC20;

    Lender public lender;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        // using ethereum fork rpc
        uint256 network = vm.createFork("https://eth.llamarpc.com");
        vm.selectFork(network);
        startHoax(user);
        lender = new Lender();
        deal(USDT, address(lender), 10_000_000e8);
        IERC20(USDT).safeIncreaseAllowance(address(lender), type(uint256).max);
    }

    function testBorrow(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < 10_000_000e8);
        lender.borrow(amount);
        uint256 borrowerDebt = lender.borrowerDebts(user);
        uint256 receivedUSDT = IERC20(USDT).balanceOf(user);
        uint256 debtWithInterest = amount.mulDiv(110, 100);
        assertEq(receivedUSDT, amount);
        assertEq(borrowerDebt, debtWithInterest);
    }

    function testZeroBorrow() public {
        vm.expectRevert();
        lender.borrow(0);
    }

    function testRepay(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < 10_000_000e8);
        lender.borrow(amount);
        uint256 _amountWithInterest = amount.mulDiv(110, 100);
        // deal the token with amount with interest
        deal(USDT, user, _amountWithInterest);
        lender.repay();
    }

    function testRepayWithoutInterest() public {
        lender.borrow(100);
        // Not enough interest
        vm.expectRevert();
        lender.repay();
    }
}
