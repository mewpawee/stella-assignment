pragma solidity ^0.8.19;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

// @notice the goal is to distributed fair reward every second to the depositor
// where the user's current accumulated reward per share will sync to the current state every transaction call
contract StakingRewarder {
    using SafeERC20 for IERC20;

    address public immutable token;
    address public immutable rewardToken;
    uint256 public rewardRatePerSec; // total reward to be distributed per second (to be shared evenly among depositors based on deposit amt)
    mapping(address => uint256) public depositBalances;
    mapping(address => uint256) public rewardBalances;

    uint256 public accumulatedRewardPerShare; // lastest accumulateRewardPerShare
    mapping(address => uint256) public userAccumulatedRewardPerShare; // mapping of user to user's latest accumulateRewardPerShare State

    uint256 public lastTimestamp;
    uint256 public totalShare;

    uint256 private constant ACC_PRECISION = 1e12; // add some precision to avoid losing significant numbers when dividing.

    // Events
    event UpdateReward(uint256 indexed timestamp, uint256 accumulatedRewardPerShare);
    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);
    event ClaimAllRewards(address indexed sender, uint256 amount);

    constructor(address _token, address _rewardToken, uint256 _rewardRatePerSec) {
        token = _token;
        rewardToken = _rewardToken;
        rewardRatePerSec = _rewardRatePerSec;
    }

    // @dev function to update accumulatedRewardPerShare, rewardBalances,
    // userAccumulatedRewardPerShare and lastTimestamp
    function _updateReward() internal {
        uint256 currentTimestamp = block.timestamp;
        uint256 deltaTime = currentTimestamp - lastTimestamp;
        // calculate only the when the timestamp changed
        if (deltaTime > 0) {
            if (totalShare > 0) {
                // delta time is in milliseconds, so it needs to be divided by 1000 to represent a second.
                // use ACC_PRECISION to prevent precision loss from dividing.
                accumulatedRewardPerShare += (rewardRatePerSec * deltaTime) * ACC_PRECISION / (1000 * totalShare);
                // the user's share is multiplied by the difference of accumulatedRewardPerShare compared to the previous state.
                uint256 userAccumulatedRewardAmount = depositBalances[msg.sender]
                    * (accumulatedRewardPerShare - userAccumulatedRewardPerShare[msg.sender]);
                // add the user's reward record, using ACC_PRECISION to restore the original amount.
                rewardBalances[msg.sender] += userAccumulatedRewardAmount / ACC_PRECISION;
                // reset the user's accumulatedRewardPerShare state to the latest accumulatedRewardPerShare.
                userAccumulatedRewardPerShare[msg.sender] = accumulatedRewardPerShare;
            }
            lastTimestamp = currentTimestamp;
            emit UpdateReward(lastTimestamp, accumulatedRewardPerShare);
        }
    }

    function deposit(uint256 _amt) external {
        _updateReward();
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amt);
        depositBalances[msg.sender] += _amt;
        totalShare += _amt;
        emit Deposit(msg.sender, _amt);
    }

    function withdraw(uint256 _amt) external {
        _updateReward();
        depositBalances[msg.sender] -= _amt;
        totalShare -= _amt;
        IERC20(token).safeTransfer(msg.sender, _amt);
        emit Withdraw(msg.sender, _amt);
    }

    function claimAllRewards() external {
        // need to also update here to get the update user's reward balance befor the claim
        _updateReward();
        uint256 rewardAmount = rewardBalances[msg.sender];
        rewardBalances[msg.sender] = 0;
        IERC20(rewardToken).safeTransfer(msg.sender, rewardAmount);
        emit ClaimAllRewards(msg.sender, rewardAmount);
    }
}
