// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Utils
/// @notice A simple library with helper functions for token transfers and math operations.
library Utils {
    /// @notice Safely transfer tokens using low-level call.
    /// @param token The ERC20 token address
    /// @param to The recipient address
    /// @param amount The amount to transfer
    function safeTransfer(address token, address to, uint256 amount) internal {
        // We use low-level call to support tokens that do not return a boolean.
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                bytes4(keccak256("transfer(address,uint256)")),
                to,
                amount
            )
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Utils: Transfer failed");
    }

    /// @notice Calculate the minimum of two numbers
    /// @param a First number
    /// @param b Second number
    /// @return The minimum value
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @notice Calculate basis points (for fees or slippage calculations)
    /// @param amount The amount to apply basis points to
    /// @param bps Basis points (1 bps = 0.01%)
    /// @return Result after applying basis points
    function applyBps(uint256 amount, uint256 bps) internal pure returns (uint256) {
        return (amount * bps) / 10_000;
    }
}
