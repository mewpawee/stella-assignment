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

    uint256 public accumulatedRewardPerShare;
    mapping(address => uint256) publicuserAccumulatedRewardPerShare;

    uint256 public lastTimestamp;
    uint256 public totalShare;

    event UpdateReward(uint256 indexed timestamp, uint256 accumulatedRewardPerShare);
    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);
    event ClaimAllRewards(address indexed sender, uint256 amount);

    constructor(address _token, address _rewardToken, uint256 _rewardRatePerSec) {
        token = _token;
        rewardToken = _rewardToken;
        rewardRatePerSec = _rewardRatePerSec;
    }

    function _updateReward() internal {
        uint256 _currentTimestamp = block.timestamp;
        uint256 _deltaTime = _currentTimestamp - lastTimestamp;
        // update the accumulatedRewardPershare from the delta time
        if (_deltaTime > 0 && totalShare != 0) {
            // accumulatedRewardPerShare += (rewardRatePerSec / totalShare) * deltaTime / 1000
            // delta time is in milliseconds so it need to divide by 1000 to be a second
            accumulatedRewardPerShare += (rewardRatePerSec * _deltaTime) / (1000 * totalShare);
            // the different between the accumulatedRewardPerShare of the current state and the last user record
            uint256 _userAccumulatedRewardAmount =
                (accumulatedRewardPerShare - userAccumulatedRewardPerShare[msg.sender]) * depositBalances[msg.sender];
            // add user's reward record
            rewardBalances[msg.sender] += _userAccumulatedRewardAmount;
            // reset the user accumaratedRewardPershare to lastest accumaratedRewardPershare
            userAccumulatedRewardPerShare[msg.sender] = accumulatedRewardPerShare;
        }
        lastTimestamp = _currentTimestamp;
        emit UpdateReward(_currentTimestamp, accumulatedRewardPerShare);
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
        _updateReward();
        uint256 _rewardAmount = rewardBalances[msg.sender];
        rewardBalances[msg.sender] = 0;
        IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);
        emit ClaimAllRewards(msg.sender, _rewardAmount);
    }
}
