pragma solidity 0.8.20;

/// @dev Lender Contract functions
interface ILender {
    function borrow(uint256 amount) external;
    function repay() external;
}
