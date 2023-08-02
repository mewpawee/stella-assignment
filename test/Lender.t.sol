// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/Test.sol";
import {Lender} from "../src/Lender.sol";

contract LenderTest is Test {
    Lender public lender;
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function setUp() public {
        uint256 network = vm.createFork("https://1rpc.io/eth");
        vm.selectFork(network);
        lender = new Lender();
        deal(USDT, address(lender), 10_000_000e8);
    }

    function testBorrow() public {
        console.log(address(lender));
    }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
