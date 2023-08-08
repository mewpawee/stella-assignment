pragma solidity 0.8.20;

/// @dev Lender Contract interface
interface ILender {
    // error
    error ZeroAmount();
    error NotEnoughBalance();

    // function
    function borrow(uint256 amount) external;
    function repay() external;
}
