// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {StakingRewarder} from "../contracts/StakingRewarder.sol";

contract StakingRewarderTest is Test {
    using SafeERC20 for IERC20;

    StakingRewarder public stakingRewarder;
    address private constant user1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address private constant user2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address private constant user3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private constant ALPHA = 0xa1faa113cbE53436Df28FF0aEe54275c13B40975;

    function setUp() public {
        // using ethereum fork rpc
        uint256 network = vm.createFork("https://eth.llamarpc.com");
        vm.selectFork(network);
        startHoax(user1);
        stakingRewarder = new StakingRewarder(USDT,ALPHA,100);
        deal(USDT, address(user1), 10_000_000e8);
        deal(USDT, address(user2), 10_000_000e8);
        deal(USDT, address(user3), 10_000_000e8);
        deal(ALPHA, address(stakingRewarder), 10_000_000e8);
        IERC20(USDT).safeIncreaseAllowance(address(stakingRewarder), type(uint256).max);
        startHoax(user2);
        IERC20(USDT).safeIncreaseAllowance(address(stakingRewarder), type(uint256).max);
        startHoax(user3);
        IERC20(USDT).safeIncreaseAllowance(address(stakingRewarder), type(uint256).max);
    }

    // @dev simple run though scenerio, don't concerns about the token decimals
    function testScenerio() public {
        startHoax(user1);
        stakingRewarder.deposit(5);
        startHoax(user2);
        stakingRewarder.deposit(12);
        startHoax(user3);
        stakingRewarder.deposit(3);
        // jump to the next 10 seconds
        vm.warp(block.timestamp + 10_000);
        startHoax(user3);
        // user3's claim all rewards after 10 seconds pass
        stakingRewarder.claimAllRewards();
        uint256 accRewardPerShare1 = stakingRewarder.accumulatedRewardPerShare();
        uint256 user3Reward1 = IERC20(ALPHA).balanceOf(user3);
        // current should be is (100/20)* 10 = 50 per share
        console.log("AccumulatedRewardPerShare1", accRewardPerShare1);
        // user3'reward should update to 50 * 3 = 150 tokens
        console.log("User3RewardToken1", user3Reward1);
        // jump to the next 5 seconds
        vm.warp(block.timestamp + 5_000);
        // user3's claim all rewards after 5 seconds pass
        stakingRewarder.claimAllRewards();
        uint256 accRewardPerShare2 = stakingRewarder.accumulatedRewardPerShare();
        uint256 user3Reward2 = IERC20(ALPHA).balanceOf(user3);
        // current should be is (100/20)* 10 + (100/20) * 5 = 75 per share
        console.log("AccumulatedRewardPerShare2", accRewardPerShare2);
        // user3'reward should update to 3(50) + 3(75-50)= 225 tokens
        console.log("User3RewardToken2", user3Reward2);
        // jump to the next 5 seconds
        vm.warp(block.timestamp + 5_000);
        startHoax(user1);
        // user1's withdraw all balance
        stakingRewarder.withdraw(5);
        uint256 accRewardPerShare3 = stakingRewarder.accumulatedRewardPerShare();
        // get user1's rewardBalance record
        uint256 user1RewardBalance3 = stakingRewarder.rewardBalances(user1);
        // get current total share
        uint256 totalRemainingShare = stakingRewarder.totalShare();

        // current should be is (100/20)* 10 + (100/20) * 5 + (100/20) * 5 = 100 per share
        console.log("AccumulatedRewardPerShare3", accRewardPerShare3);
        // user1'reward should update to 5 * 100 = 500 tokens
        console.log("User1RewardBalance3", user1RewardBalance3);
        console.log("TotalRemainingShare", totalRemainingShare);
    }
}
